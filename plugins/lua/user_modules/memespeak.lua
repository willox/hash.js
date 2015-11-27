local emotes = {
	[" "] = "  ",
	a = ":csgoa:",
	b = ":csgob:",
	c = ":carbon:",
	d = ":thed:",
	e = ":elementsigma:",
	f = ":fluorine:",
	g = ":gmod:",
	h = ":hyperion:",
	i = ":patrol:",
	j = ":journeyj:",
	k = ":civilwarsoldier:",
	l = ":collectible:",
	m = ":corporatebranding:",
	n = ":Teddy_Exit:",
	o = ":chopyouup:",
	p = ":P:",
	q = ":hypercube:",
	r = ":memory:",
	s = ":cowcredits:",
	t = ":knightcross:",
	u = ":GoldHorseShoe:",
	v = ":flying:",
	w = ":warband:",
	x = ":tinyjigsaw:",
	y = ":Y:",
	z = ":Z:",
}
hook.Add("Message", "memespeak", function(ply, id, txt)
	if string.sub(txt, 1, 2) == ">>" then
		txt = string.sub(txt, 3)
		txt = string.lower(txt)
		txt = string.gsub(txt, ".", emotes)
		print(txt)
	end
end)
