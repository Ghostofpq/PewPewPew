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
            x=30,
            y=324,
            width=4,
            height=10,

        },
        {
            -- level_background
            x=0,
            y=0,
            width=200,
            height=320,

        },
        {
            -- main_vaisseau
            x=0,
            y=324,
            width=26,
            height=30,

        },
    },
    
    sheetContentWidth = 200,
    sheetContentHeight = 354
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
