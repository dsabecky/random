####################################################################
# Library & Modules
####################################################################

# discord imports
import discord
from discord.ext import commands
import concurrent.futures

# system
import docker
import asyncio

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
        self.loop = asyncio.get_event_loop()

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
    async def trigger_docker(self, ctx):
        """Docker commands."""
        if ctx.invoked_subcommand is None:
            raise FancyError(ERROR_CODES["syntax"])

    @trigger_docker.command(name="ps")
    @requires_owner_perms()
    async def trigger_docker_ps(self, ctx):
        """List running Docker containers."""
        title = "🐋 Docker Containers"
        containers = sorted(self.docker_client.containers.list(), key=lambda x: x.name)

        if not containers:
            await ctx.reply(embed=build_embed(title, "No running containers.", 'p'), allowed_mentions=discord.AllowedMentions.none())
            return
        
        msg = "\n".join(f"{i+1}. {c.name} → {c.status}" for i, c in enumerate(containers))
        await ctx.reply(embed=build_embed(title, msg, 'p'), allowed_mentions=discord.AllowedMentions.none())

    @trigger_docker.command(name="restart", aliases=["reboot"])
    @requires_owner_perms()
    async def trigger_docker_restart(self, ctx, container_name: str):
        """Restart a Docker container."""
        try:
            container = self.docker_client.containers.get(container_name)
            await ctx.reply(embed=build_embed("🐋 Docker Restart", f"Restarting {container_name}.", 'g'), allowed_mentions=discord.AllowedMentions.none())
            container.restart()

        except Exception as e:
            raise FancyError(f"Error: {e}")

    @trigger_docker.command(name="start")
    @requires_owner_perms()
    async def trigger_docker_start(self, ctx, container_name: str):
        """Start a Docker container."""
        try:
            container = self.docker_client.containers.get(container_name)
            await ctx.reply(embed=build_embed("🐋 Docker Start-Up", f"Starting {container_name}.", 'g'), allowed_mentions=discord.AllowedMentions.none())
            container.start()
            
        except Exception as e:
            raise FancyError(f"Error: {e}")

    @trigger_docker.command(name="stats")
    @requires_owner_perms()
    async def trigger_docker_stats(self, ctx) -> None:
        """Get stats for a Docker container."""

        title = "🐋 Docker Stats"
        containers = self.docker_client.containers.list()
        if not containers:
            await ctx.reply(embed=build_embed(title, "No running containers.", 'p'), allowed_mentions=discord.AllowedMentions.none()); return

        message = await ctx.reply(embed=build_embed(title, "Gathering stats...", 'g'), allowed_mentions=discord.AllowedMentions.none())

        def get_stats(container):
            stats = container.stats(stream=False)
            cpu_local = stats['cpu_stats']['cpu_usage']['total_usage'] - stats['precpu_stats']['cpu_usage']['total_usage']
            cpu_system = stats['cpu_stats']['system_cpu_usage'] - stats['precpu_stats']['system_cpu_usage']

            try:
                cpu_usage = (cpu_local / cpu_system) * len(stats['cpu_stats']['cpu_usage']['percpu_usage']) * 100
            except ZeroDivisionError:
                cpu_usage = 0.0
            
            mem_usage = f"{stats['memory_stats']['usage'] / (1024 ** 2):.0f}MB / {stats['memory_stats']['limit'] / (1024 ** 3):.0f}GB"
            return { 'name': container.name, 'mem_usage': mem_usage, 'cpu_usage': f"{cpu_usage:.2f}%" }

        with concurrent.futures.ThreadPoolExecutor() as executor:
            container_stats = await self.loop.run_in_executor(executor, lambda: [get_stats(c) for c in containers])

        output = "\n".join(f"{i+1}. **{c['name']}** → 🧠 RAM: {c['mem_usage']}  🖥️ CPU: {c['cpu_usage']}" for i, c in enumerate(container_stats))
        await message.edit(embed=build_embed(title, output, 'g'), allowed_mentions=discord.AllowedMentions.none())

    @trigger_docker.command(name="stop", aliases=["shutdown"])
    @requires_owner_perms()
    async def trigger_docker_stop(self, ctx, container_name: str):
        """Stop a Docker container."""

        if container_name == self.get_own_container_name():
            raise FancyError("Self preservation engaged. Denying request.")
        
        try:
            container = self.docker_client.containers.get(container_name)
            await ctx.reply(embed=build_embed("🐋 Docker Shutdown", f"Stopping {container_name}.", 'g'), allowed_mentions=discord.AllowedMentions.none())
            container.stop()

        except Exception as e:
            raise FancyError(f"Error: {e}")


####################################################################
# Launch Cog
####################################################################

async def setup(bot: commands.Bot):
    log_cog.info("🐋 Loading [dark_orange]Docker[/] cog…")
    await bot.add_cog(Docker(bot))