/** @param {NS} ns */
export async function main(ns) {
	// server list
	const s = ["home", "foodnstuff", "sigma-cosmetics", "joesguns", "nectar-net", "silver-helix", "phantasy", "CSEC", "neo-net", "max-hardware", "hong-fang-tea","harakiri-sushi", "iron-gym", "zer0", "omega-net", "the-hub", "syscore", "computek", "rothman-uni", "johnson-ortho", "I.I.I.I", "crush-fitness", "netlink", "avmnite-02h", "zb-institute", "summit-uni", "catalyst"];
	const r = (Math.floor(Math.random() * 5) + 1) * 1000

	function runBot(host) {
		ns.exec("z.js",host,1);
	}

	for (let i = 0; i < s.length; i++) {
		if (ns.hasRootAccess(s[i])) {
			setTimeout(runBot(s[i]), r)
		}
	}
}