####################################################################
# Library & Modules
####################################################################

# discord imports
import discord
from discord.ext import commands
from discord.ext.commands import Greedy, Context

# system
import docker

# hathor internals
from func import ERROR_CODES, FancyError # error handling
from func import build_embed # functions
from func import requires_owner_perms # permission checks
from logs import log_cog # logging

####################################################################
# Classes
####################################################################

class Docker(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        self.docker_client = docker.from_env()

    ####################################################################
    # Functions
    ####################################################################

    def get_own_container_name(self) -> str:
        """Get the name of the container that is running this script."""

        container_id = open('/proc/self/cgroup', 'r').read().split('/')[-1].strip()
        # Sometimes the container ID is not the last line, so let's be robust:
        with open('/proc/self/cgroup', 'r') as f:
            for line in f:
                if 'docker' in line:
                    container_id = line.strip().split('/')[-1]
                    break

        container = self.docker_client.containers.get(container_id)
        return container.name


    ####################################################################
    # Command triggers
    ####################################################################

    @commands.group(name="docker")
    @requires_owner_perms()
    async def docker(self, ctx):
        """Docker commands."""
        if ctx.invoked_subcommand is None:
            raise FancyError(ERROR_CODES["syntax"])

    @docker.command(name="ps")
    @requires_owner_perms()
    async def trigger_docker_ps(self, ctx):
        """List running Docker containers."""
        containers = sorted(self.docker_client.containers.list(), key=lambda x: x.name)

        if not containers:
            await ctx.reply(embed=build_embed("🐋 Docker", "🚫 No running containers.", 'p'), allowed_mentions=discord.AllowedMentions.none())
            return
        
        msg = "\n".join(f"{i+1}. {c.name} → {c.status}" for i, c in enumerate(containers))
        await ctx.reply(embed=build_embed("🐋 Docker", msg, 'p'), allowed_mentions=discord.AllowedMentions.none())

    @docker.command(name="restart")
    @requires_owner_perms()
    async def trigger_docker_restart(self, ctx, container_name: str):
        """Restart a Docker container."""
        try:
            container = self.docker_client.containers.get(container_name)
            await ctx.reply(embed=build_embed("🐋 Docker", f"🔄 Restarting `{container_name}`.", 'g'), allowed_mentions=discord.AllowedMentions.none())
            container.restart()

        except Exception as e:
            raise FancyError(f"Error: {e}")

    @docker.command(name="start")
    @requires_owner_perms()
    async def trigger_docker_start(self, ctx, container_name: str):
        """Start a Docker container."""
        try:
            container = self.docker_client.containers.get(container_name)
            await ctx.reply(embed=build_embed("🐋 Docker", f"🟢 Starting `{container_name}`.", 'g'), allowed_mentions=discord.AllowedMentions.none())
            container.start()
            
        except Exception as e:
            raise FancyError(f"Error: {e}")

    @docker.command(name="stop")
    @requires_owner_perms()
    async def trigger_docker_stop(self, ctx, container_name: str):
        """Stop a Docker container."""

        if container_name == self.get_own_container_name():
            raise FancyError("Self preservation engaged. Denying request.")
        
        try:
            container = self.docker_client.containers.get(container_name)
            await ctx.reply(embed=build_embed("🐋 Docker", f"🛑 Stopping `{container_name}`.", 'g'), allowed_mentions=discord.AllowedMentions.none())
            container.stop()

        except Exception as e:
            raise FancyError(f"Error: {e}")


####################################################################
# Launch Cog
####################################################################

async def setup(bot: commands.Bot):
    log_cog.info("Loading [dark_orange]Docker[/] cog…")
    await bot.add_cog(Docker(bot))