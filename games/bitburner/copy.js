/** @param {NS} ns */
export async function main(ns) {
	// server list
	const s = ["n00dles", "foodnstuff", "sigma-cosmetics", "joesguns", "nectar-net", "silver-helix", "phantasy", "CSEC", "neo-net", "max-hardware", "hong-fang-tea","harakiri-sushi", "iron-gym", "zer0", "omega-net", "the-hub", "syscore", "computek", "rothman-uni", "johnson-ortho", "I.I.I.I", "crush-fitness", "netlink", "avmnite-02h", "zb-institute", "summit-uni", "catalyst"];

	for (let i = 0; i < s.length; i++) {
		ns.toast(`Copying hack to ${s[i]}...`, "info", 5000);
		await ns.scp("z.js",s[i]);
	}
}