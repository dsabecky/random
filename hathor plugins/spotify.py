####################################################################
# Library & Modules
####################################################################

# discord imports
import discord
from discord import app_commands
from discord.ext import commands

# spotify imports
import spotipy
from spotipy.exceptions import SpotifyException
from spotipy.oauth2 import SpotifyOAuth

# system level stuff
from io import BytesIO
import os

# data analysis
from datetime import datetime, timedelta
from collections import Counter
import requests
from PIL import Image, ImageDraw, ImageFont
import urllib.parse
import json

# hathor internals
import data.config as config
from hathor import log_sys


####################################################################
# Configuration
####################################################################

IMAGE_FONT_PATH = config.IMAGE_FONT_PATH


####################################################################
# Functions
####################################################################

def draw_outlined_text(draw, position, text, font, fill, outline_color, outline_width):
    x, y = position
    # Draw outline
    for dx in range(-outline_width, outline_width + 1):
        for dy in range(-outline_width, outline_width + 1):
            if dx != 0 or dy != 0:
                draw.text((x + dx, y + dy), text, font=font, fill=outline_color)
    # Draw main text
    draw.text((x, y), text, font=font, fill=fill)

def truncate_text(text, font, max_width, draw):
    ellipsis = "…"
    if draw.textlength(text, font=font) <= max_width:
        return text
    while draw.textlength(text + ellipsis, font=font) > max_width and len(text) > 0:
        text = text[:-1]
    return text + ellipsis if text else ""


####################################################################
# Cog
####################################################################

class Spotify(commands.Cog):
    def __init__(self, bot):
        self.bot = bot

    @app_commands.command(name="spotifyauth", description="Authenticate your Spotify account")
    async def spotifyauth(self, interaction: discord.Interaction):
        if not isinstance(interaction.channel, discord.DMChannel):
            await interaction.response.send_message("Please use this command in DMs for privacy.", ephemeral=True)
            return

        cache_path = f"{config.SPOTIFY_CACHE_PATH}/.cache-{interaction.user.id}"
        parent_dir = os.path.dirname(cache_path)
        os.makedirs(parent_dir, exist_ok=True)

        sp_oauth = SpotifyOAuth(
            client_id=config.SPOTIFY_CLIENT_ID,
            client_secret=config.SPOTIFY_CLIENT_SECRET,
            redirect_uri=config.SPOTIFY_REDIRECT_URI,
            scope='user-top-read user-read-recently-played',
            show_dialog=True,
            cache_path=cache_path
        )
        auth_url = sp_oauth.get_authorize_url()
        await interaction.response.send_message(
            f"Please authenticate with Spotify by clicking this link:\n{auth_url}\n"
            "After authorizing, paste the **full URL** you were redirected to here."
        )

        def check(m):
            return m.author.id == interaction.user.id and isinstance(m.channel, discord.DMChannel)

        try:
            msg = await self.bot.wait_for('message', check=check, timeout=300)
        except Exception:
            await interaction.followup.send("Timed out. Please try again.")
            return

        parsed = urllib.parse.urlparse(msg.content)
        code = urllib.parse.parse_qs(parsed.query).get('code')
        if not code:
            await interaction.followup.send("Could not find code in the URL. Please try again.")
            return
        code = code[0]

        token_info = sp_oauth.get_access_token(code)
        if not token_info:
            await interaction.followup.send("Failed to authenticate. Please try again.")
            return

        cache_path = f"{config.SPOTIFY_CACHE_PATH}/.cache-{interaction.user.id}"
        with open(cache_path, "w") as f:
            json.dump(token_info, f)

        await interaction.followup.send("Spotify authentication successful! You can now use `/5x5`.")

    @app_commands.command(name="5x5", description="Show your 5x5 most played albums from the last 7 days")
    async def five_by_five(self, interaction: discord.Interaction):
        await interaction.response.defer()

        cache_path = f"{config.SPOTIFY_CACHE_PATH}/.cache-{interaction.user.id}"
        parent_dir = os.path.dirname(cache_path)
        os.makedirs(parent_dir, exist_ok=True)

        if not os.path.exists(cache_path):
            await interaction.followup.send("You need to authenticate first using `/spotifyauth` in DMs.")
            return

        with open(cache_path, "r") as f:
            token_info = json.load(f)

        if not token_info:
            await interaction.followup.send("You need to authenticate first using `/spotifyauth` in DMs.")
            return

        sp_oauth = SpotifyOAuth(
            client_id=config.SPOTIFY_CLIENT_ID,
            client_secret=config.SPOTIFY_CLIENT_SECRET,
            redirect_uri=config.SPOTIFY_REDIRECT_URI,
            scope='user-top-read user-read-recently-played',
            cache_path=cache_path
        )
        if sp_oauth.is_token_expired(token_info):
            token_info = sp_oauth.refresh_access_token(token_info['refresh_token'])
            with open(cache_path, "w") as f:
                json.dump(token_info, f)

        sp = spotipy.Spotify(auth=token_info['access_token'])

        
        items, limit, next, offset = [], 50, True, 0
        while next:
            try:
                results = sp.current_user_top_tracks(limit=limit, offset=offset, time_range="short_term")

            except SpotifyException as e:
                if e.http_status == 403 and "developer" in str(e).lower():
                    await interaction.followup.send("This Spotify application is in Developer Mode, and the developer must manually enable your access.")
                    return
                else:
                    await interaction.followup.send("An error occurred while accessing Spotify. Please try again later.")
                    return
                
            items.extend(results.get('items', []))
            next  = results.get('next')

            if next:
                parse_url = urllib.parse.urlparse(next)
                offset = int(urllib.parse.parse_qs(parse_url.query).get('offset')[0])
                limit = int(urllib.parse.parse_qs(parse_url.query).get('limit')[0])

        album_counter = Counter()
        album_info = {}
        for item in items:
            album = item['album']
            album_id = album['id']
            album_counter[album_id] += 1
            if album_id not in album_info:
                album_info[album_id] = {
                    'name': album['name'],
                    'artist': album['artists'][0]['name'],
                    'image_url': album['images'][0]['url'] if album['images'] else None
                }

        top_albums = album_counter.most_common(25)
        if not top_albums:
            await interaction.followup.send("No albums found in your last 7 days of listening.")
            return

        images = []
        for album_id, _ in top_albums:
            url = album_info[album_id]['image_url']
            if url:
                response = requests.get(url)
                img = Image.open(BytesIO(response.content)).convert("RGB")
                images.append(img)
            else:
                images.append(Image.new("RGB", (300, 300), color=(40, 40, 40)))

        size = 300
        grid_img = Image.new("RGB", (size * 5, size * 5), color=(24, 24, 24))
        for idx, img in enumerate(images):
            img = img.resize((size, size))
            x = (idx % 5) * size
            y = (idx // 5) * size
            grid_img.paste(img, (x, y))

        size = 300
        grid_img = Image.new("RGB", (size * 5, size * 5), color=(24, 24, 24))

        # Load your UbuntuMono font
        font_path = IMAGE_FONT_PATH
        try:
            font = ImageFont.truetype(font_path, 18)
        except IOError:
            font = ImageFont.load_default()

        def draw_outlined_text(draw, position, text, font, fill, outline_color, outline_width):
            x, y = position
            # Draw outline
            for dx in range(-outline_width, outline_width + 1):
                for dy in range(-outline_width, outline_width + 1):
                    if dx != 0 or dy != 0:
                        draw.text((x + dx, y + dy), text, font=font, fill=outline_color)
            # Draw main text
            draw.text((x, y), text, font=font, fill=fill)

        max_text_width = 280  # Adjust as needed for your padding

        for idx, (album_id, _) in enumerate(top_albums):
            img = images[idx].resize((size, size))
            draw = ImageDraw.Draw(img)
            artist = album_info[album_id]['artist']
            album = album_info[album_id]['name']

            # Truncate text if too long
            artist_trunc = truncate_text(artist, font, max_text_width, draw)
            album_trunc = truncate_text(album, font, max_text_width, draw)

            draw_outlined_text(
                draw,
                (8, 8),
                artist_trunc,
                font=font,
                fill="white",
                outline_color="black",
                outline_width=2
            )
            draw_outlined_text(
                draw,
                (8, 32),
                album_trunc,
                font=font,
                fill="white",
                outline_color="black",
                outline_width=2
            )

            x = (idx % 5) * size
            y = (idx // 5) * size
            grid_img.paste(img, (x, y))

        buffer = BytesIO()
        grid_img.save(buffer, format="PNG")
        buffer.seek(0)
        file = discord.File(fp=buffer, filename="5x5.png")
        await interaction.followup.send(file=file)

async def setup(bot):
    log_sys.info("🎶 Loading [lime_green]Spotify[/lime_green] cog...")
    await bot.add_cog(Spotify(bot))