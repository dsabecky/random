####################################################################
# Library & Modules
####################################################################

from discord.ext import commands
import radarr
from radarr.rest import ApiException
from logs import log_cog
import json
from func import FancyError, build_embed
from data.config import RADARR_URL, RADARR_APIKEY, RADARR_MOVIE_ROOT


####################################################################
# Classes
####################################################################

class Radarr(commands.Cog):
    def __init__(self, bot):
        self.bot = bot

    def radarr_config(self):
        configuration = radarr.Configuration(host=RADARR_URL)
        configuration.api_key['X-Api-Key'] = RADARR_APIKEY
        return configuration

    async def lookup_movie(self, term):
        def _lookup():
            with radarr.ApiClient(self.radarr_config()) as api_client:
                lookup_api = radarr.MovieLookupApi(api_client)
                return lookup_api.list_movie_lookup(term=term)
            
        return await self.bot.loop.run_in_executor(None, _lookup)

    async def add_movie(self, movie):
        def _add():
            with radarr.ApiClient(self.radarr_config()) as api_client:
                movie_api = radarr.MovieApi(api_client)
                add_payload = radarr.MovieResource(
                    title=movie.title,
                    quality_profile_id=1,
                    title_slug=movie.title_slug,
                    images=movie.images,
                    tmdb_id=movie.tmdb_id,
                    year=movie.year,
                    root_folder_path=RADARR_MOVIE_ROOT,
                    monitored=True,
                    add_options=radarr.AddMovieOptions(search_for_movie=True)
                )
                return movie_api.create_movie(add_payload)
        return await self.bot.loop.run_in_executor(None, _add)


    ####################################################################
    # Command triggers
    ####################################################################

    @commands.group(name="radarr", invoke_without_command=True)
    async def trigger_radarr(self, ctx) -> None:
        if ctx.invoked_subcommand is None:
            await ctx.send_help(ctx.command)

    @trigger_radarr.command(name="add")
    async def trigger_radarr_add(self, ctx, *, query: str) -> None:
        """
        BOT OWNER. Searches for a movie and adds it to Radarr.

        Syntax:
            !radarr add <movie title>
        """

        message = await ctx.send(embed=build_embed(f"🎬 Radarr", f"⌛ Searching for `{query}`…", "p"))

        try:
            results = await self.lookup_movie(query)
        except Exception as e:
            await message.delete(); raise FancyError(e)
        
        try:
            movie = results[0]
        except Exception:
            await message.edit(embed=build_embed("🎬 Radarr", "❌ No results found.", "r")); return

        if not results:
            await message.delete(); raise FancyError(f"❌ No results found for `{query}`.")

        embed = build_embed(f"{movie.title} ({movie.year})", movie.overview or "No synopsis.", "p")
        embed.add_field(name="TMDB ID", value=movie.tmdb_id, inline=True)
        embed.add_field(name="Year", value=movie.year, inline=True)
        embed.set_footer(text="React ✅ to confirm, ❌ to cancel. 30s timeout.")

        if movie.images and movie.images[0].remote_url: # add poster if available
            embed.set_thumbnail(url=movie.images[0].remote_url)
        
        await message.edit(embed=embed)
        await message.add_reaction("✅"); await message.add_reaction("❌")

        def check(reaction, user):
            return user == ctx.author and reaction.message.id == message.id and str(reaction.emoji) in ("✅", "❌")

        try:
            reaction, _ = await self.bot.wait_for("reaction_add", timeout=30.0, check=check)
        except Exception:
            await message.edit(embed=build_embed("🎬 Radarr", "⌛ Timed out, cancelled.", "r")); return

        if str(reaction.emoji) == "❌":
            await message.edit(embed=build_embed("🎬 Radarr", "❌ Cancelled.", "r"))
            await message.clear_reactions()
            return

        try:
            added = await self.add_movie(movie)
            await message.edit(embed=build_embed("🎬 Radarr", f"✅ Added **{added.title} ({added.year})**.", "g"))
            await message.clear_reactions()
        except ApiException as e:
            errors = json.loads(e.body)
            for error in errors:
                if error.get('errorMessage'):
                    await message.edit(embed=build_embed("🎬 Radarr", f"❌ {error.get('errorMessage')}.", "r"))
                    await message.clear_reactions()
                    return

            await message.clear_reactions()
            await message.delete()
            raise FancyError(e)


####################################################################
# Launch Cog
####################################################################

async def setup(bot: commands.Bot):
    log_cog.info("🎬 Loading [dark_orange]Radarr[/] cog…")
    await bot.add_cog(Radarr(bot))