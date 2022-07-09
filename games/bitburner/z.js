/** @param {NS} ns */
export async function main(ns) {
	// server list
	const s = ["n00dles", "foodnstuff", "sigma-cosmetics", "joesguns", "nectar-net", "silver-helix", "phantasy", "neo-net", "max-hardware", "hong-fang-tea","harakiri-sushi", "iron-gym", "zer0", "omega-net", "the-hub", "syscore", "computek", "rothman-uni", "johnson-ortho", "I.I.I.I", "crush-fitness", "netlink", "avmnite-02h", "zb-institute", "summit-uni", "catalyst"];
	// ignore grow/weak list
	const b = ["iron-gym"]

	// shuffle the server list
	for (let i = s.length -1; i > 0; i--) {
		let j = Math.floor(Math.random() * i)
		let k = s[i]
		s[i] = s[j]
		s[j] = k
	}

	while (true) {
		const q = [];

		// start running against each server
		for (let i = 0; i < s.length; i++) {
			// same some time retyping these
			const host = s[i];
			const slvl = ns.getServerSecurityLevel(host).toFixed(2)
			const mlvl = ns.getServerMinSecurityLevel(host).toFixed(2)
			const cash = ns.getServerMoneyAvailable(host).toFixed(2)

			// if we need to weaken, then weaken
			if (ns.hasRootAccess(host) && slvl >= 10 && slvl > mlvl + 5 && !b.includes(host)) { ns.toast(`Weakening ${host} from ${ns.getHostname()} (${slvl}).`, "warning", 10000); q.push(await ns.weaken(host)); }

			// if we need to grow, then grow.
			if (ns.hasRootAccess(host) && cash < 100000 && !b.includes(host)) { ns.toast(`Growing ${host} from ${ns.getHostname()}, (${cash}).`, "warning", 10000); q.push(await ns.grow(host)); }

			// can hack? hack.
			else if (ns.hasRootAccess(host)) { ns.toast(`Hacking ${host} from ${ns.getHostname()}...`, "success", 3000); q.push(await ns.hack(host)); }
			
			// can't hack.. yet
			else {
				// do we meet port requirements?
				if (ns.getHackingLevel() >= ns.getServerRequiredHackingLevel(host)) { ns.toast(`You need open ports on ${host}..`,"error",20000) }
			}
		}

		await Promise.all(q)
	}
}