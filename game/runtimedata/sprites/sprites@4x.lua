--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:634b70be71d0ba480709c20feae222f8:8dda05ec2e3c3a1e68e178756834b5a4:f5c322b4188998d6cd973301e8657e5f$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- generated_laser
            x=120,
            y=1296,
            width=16,
            height=40,

        },
        {
            -- level_background
            x=0,
            y=0,
            width=800,
            height=1280,

        },
        {
            -- main_vaisseau
            x=0,
            y=1296,
            width=104,
            height=120,

        },
    },
    
    sheetContentWidth = 800,
    sheetContentHeight = 1416
}

SheetInfo.frameIndex =
{

    ["generated_laser"] = 1,
    ["level_background"] = 2,
    ["main_vaisseau"] = 3,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
