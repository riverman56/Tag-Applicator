local TagApplicator = {}

local TagMap = {
	Color = {
		Input = true,
		Open = [[<font color="%s">]],
		Close = [[</font>]],
	},
	Size = {
		Input = true,
		Open = [[<font size="%s">]],
		Close = [[</font>]],
	},
	FontBase = {
		Input = true,
		Open = [[<font face="%s">]],
		Close = [[</font>]],
	},
	Bold = {
		Open = [[<b>]],
		Close = [[</b>]],
	},
	Italic = {
		Open = [[<i>]],
		Close = [[</i>]],
	},
	Underline = {
		Open = [[<u>]],
		Close = [[</u>]],
	},
	Strikethrough = {
		Open = [[<s>]],
		Close = [[</s>]],
	},
	Comment = {
		Open = [[<!--]],
		Close = [[-->]],
	},
	["Line Break"] = {
		Open = [[<br />]],
	},
	["Small Caps"] = {
		Open = [[<sc>]],
		Close = [[</sc>]],
	}
}

function FindInput(tag)
	local exists, closure = string.find(tag, ":")

	if exists then
		return true, string.sub(tag, 1, closure - 1), string.sub(tag, closure + 1, string.len(tag))
	else
		return tag
	end
end

function TagApplicator:ApplyTag(rawString: string, tag: string, portion: string | nil)
	if portion then
		assert(string.find(rawString, portion) ~= nil, "Portion string not found in original string!")
	end

	local exists, tagWithoutInput, input = FindInput(tag)
	tagWithoutInput = tagWithoutInput or tag

	if exists and TagMap[tagWithoutInput].Input == true and input == nil then
		error("You have passed a tag that requires input, but you have not provided the input. Input is supplied with the following format: 'tag:input'")
	end

	assert(TagMap[tagWithoutInput] ~= nil, "Tag provided is not valid!")

	local newString
	local openingTag
	local closingTag = TagMap[tagWithoutInput].Close or ""

	if TagMap[tagWithoutInput].Input == true then
		openingTag = string.format(TagMap[tagWithoutInput].Open, input)
	else
		openingTag = TagMap[tagWithoutInput].Open
	end

	if portion then
		local beginning, closure = string.find(rawString, portion)
		newString = string.sub(rawString, 1, beginning - 1)..openingTag..string.sub(rawString, beginning, closure)..closingTag..string.sub(rawString, closure + 1, string.len(rawString))
	else
		newString = openingTag..rawString..closingTag
	end

	return newString
end

function TagApplicator:RemoveTags(rawString: string)
    return string.gsub(rawString, "(\\?)<[^<>]->", {
        [''] = ''
        }
    )
end

return TagApplicator