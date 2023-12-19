--*****************************************************--
--Confirmation dialog created before clicking on a link--
--Helps reduce people clicking on malicious links (IP Grabbers, pornographic content, trojan horses, etc)--
--*****************************************************--

require ("ISUI/ISPanel")

ISConfirmClickLink = ISPanel:derive("ISConfirmClickLink")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local function splitWords(Lines, limit)
    while #Lines[#Lines] > limit do
            Lines[#Lines+1] = Lines[#Lines]:sub(limit+1)
            Lines[#Lines-1] = Lines[#Lines-1]:sub(1,limit)
    end
end

local function wrap(str, limit)
    local Lines, here, limit, found = {}, 1, limit or 72, str:find("(%s+)()(%S+)()")

    if found then
            Lines[1] = string.sub(str,1,found-1)
    else Lines[1] = str end

    str:gsub("(%s+)()(%S+)()",
            function(sp, st, word, fi)
                    splitWords(Lines, limit)

                    if fi-here > limit then
                            here = st
                            Lines[#Lines+1] = word                                                                                  
                    else Lines[#Lines] = Lines[#Lines].." "..word end
            end)

    splitWords(Lines, limit)

    return Lines
end

function ISConfirmClickLink:initialise()
	ISPanel.initialise(self)
    local btnW, btnH = self:getWidth() * 0.15, self:getHeight() * 0.1
	self.yes = ISButton:new(self:getWidth() * 0.95 - btnW, self:getHeight() * 0.85, btnW, btnH, getText("UI_Yes"), self, ISConfirmClickLink.onClick);
    self.yes.internal = "YES";
    self.yes:initialise();
    self.yes:instantiate();
    self.yes.borderColor = {r=0, g=1, b=0, a=0.3};
    self:addChild(self.yes);

    self.no = ISButton:new(self:getWidth() * 0.2 - btnW, self:getHeight() * 0.85, btnW, btnH, getText("UI_No"), self, ISConfirmClickLink.onClick);
    self.no.internal = "NO";
    self.no:initialise();
    self.no:instantiate();
    self.no.borderColor = {r=1, g=0, b=0, a=0.3};
    self:addChild(self.no);
end

function ISConfirmClickLink:render()
    ISPanel:render()
    self:drawTextCentre("Are you sure you want to open this link?", (self:getWidth() / 2), 20 + FONT_HGT_MEDIUM + 10, 1, 1, 1, 1, UIFont.Medium)
    --self:getHeight() / 2 - getTextManger():MeasureStringY(UIFont.Small, "HEIGHT")
    local startH = 20 + FONT_HGT_SMALL + 50
    for k, v in pairs(wrap(self.url, 60)) do
        self:drawTextCentre(v, (self:getWidth() / 2), startH, 1, 1, 1, 1, UIFont.Small)
        startH = startH + 15
    end
   

end

function ISConfirmClickLink:onClick(button)
    if button.internal == "YES" then
        if isSteamOverlayEnabled() then
            activateSteamOverlayToWebPage(self.url)
        elseif isDesktopOpenSupported() then
            openUrl(self.url)
        else
            Clipboard.setClipboard(self.url)
            self.player:setHaloNote("Photo URL copied to clipboard", 220, 220, 220, 100)
        end
        self:close()
    end
    if button.internal == "NO" then
        self:close()
    end
end

function ISConfirmClickLink:new(x, y, w, h, url, player)
    local o = {}
    o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.url = url
    o.player = player
    return o
end
