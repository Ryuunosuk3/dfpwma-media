--[[ Custom Modules ]]--
--json = require "json"
-- not required, plus I uninstalled it anyways

--[[ Local Variables ]]--

local termX, termY = term.getSize()
local selectedItem = 1
local inMainMenu = true
local inOptionsMenu = false
local inTasks = false
local inSuboptionsMenu = false
local inDomoticsMenu

--[[ Menu Methods ]]--

function TaskList()
    term.clear()
    term.setTextColor(colors.yellow)
    term.setCursorPos(10, 2)
    term.write("TASKS:")
    term.setCursorPos(1, 2)
    inMainMenu = false
    inTasks = true
    for line in io.lines("/data/tasks.txt") do
        print("- "..line)
    end
    while inTasks do
        event, key = os.pullEvent("key")
        if key == keys.enter then
            inTasks = false
            inMainMenu = true
        end
    end
end

function Domotics()
    inMainMenu = false
    inTasks = false
    inOptionsMenu = false
    inDomoticsMenu = true
    selectedItem = 1
    term.clear()
    term.setCursorPos(1, 1)

    while inDomoticsMenu do
        printMenu(domoticsMenu)
        event, key = os.pullEvent("key")
        onKeyPressed(key,domoticsMenu)
    end
end

function Options()
    inMainMenu = false
    inTasks = false
    inDomoticsMenu = false
    inOptionsMenu = true
    selectedItem = 1
    term.clear()
    term.setCursorPos(1, 1)
    
    while inOptionsMenu do
        term.clear()
        term.setCursorPos(1,1)
        printMenu(optionsMenu)
        event, key = os.pullEvent("key")
        onKeyPressed(key,optionsMenu)
    end
end

function Edit()
    --[[ DOESNT WORK AT THE MOMENT BECAUSE I AM GENIUS ]]--

    --print(http.get("https://catfact.ninja/fact").readAll())
    inOptionsMenu = false
    term.clear()
    term.setCursorPos(1, 2)
    term.setTextColor(colors.white)
    term.write("Enter password:")
    term.setCursorPos(2, 4)
    term.write("> ")
    local userInput = read("*")
    if userInput == "iamgenius" then
        term.setTextColor(colors.lime)
        term.setCursorPos(2, 6)
        term.write("access granted, welcome")
        sleep(1)
        Exit()
    elseif userInput == "cum" then
        term.setTextColor(colors.red)
        term.setCursorPos(2, 5)
        term.write("not funny")
        sleep(1)
        printMenu(optionsMenu)
        inOptionsMenu = true
    else
        term.setTextColor(colors.red)
        term.setCursorPos(2, 5)
        term.write("access denied")
        sleep(1)
        printMenu(optionsMenu)
        inOptionsMenu = true
    end
end

function Exit()
    term.clear()
    term.setTextColor(colors.red)
    message = "PROGRAM TERMINATED"
    term.setCursorPos((termX/2)-#message/2, termY/2)
    term.write(message)
    term.setCursorPos(1,1)
    inMainMenu = false
end

function backToMainMenu()
    inTasks = false
    inOptionsMenu = false
    inDomoticsMenu = false
    inMainMenu = true
end

function isContraptionToggled(contraption)
    modem = rednet.open("back")
    if contraption == "crusher" then
        rednet.send(6, "get_crusher_state")
        local id, message = rednet.receive()
        if id == 6 and message == "on" then
            return true
        elseif id == 6 and message == "off" then
            return false
        end
    end
end

function crusherToggle()
        if isContraptionToggled("crusher") then
            rednet.send(6, "crusher_off")
        elseif not isContraptionToggled("crusher") then
            rednet.send(6, "crusher_on")
    end
    printMenu(domoticsMenu)
end

--[[ Menu Definition ]]--

mainMenu = {
[1] = { text = "Tasks", handler = TaskList },
[2] = { text = "Domotics", handler = Domotics },
[3] = { text = "Options", handler = Options },
[4] = { text = "Quit", handler = os.shutdown }
}

optionsMenu = {
[1] = { text = "Edit", handler = Edit },
[2] = { text = "Back", handler = backToMainMenu }
}

domoticsMenu = {
    [1] = { text = "Crusher ", handler = crusherToggle},
    [2] = { text = "Back ", handler = backToMainMenu}
}

--[[ Printing Methods ]]--

function printMenu(menu)
    term.setTextColor(colors.orange)
    term.setCursorPos(termX/3.5,2)
    term.write("*------------*")
    term.setCursorPos(termX/3.5,3)
    term.write("| Ryphone 13 |")
    term.setCursorPos(termX/3.5,4)
    term.write("*------------*")
    term.setTextColor(colors.gray)
    for i=1,#menu do
        if i == selectedItem then
            term.setCursorPos(termX/2.5, 5+i*2)
            if menu[i].text == "Back" or menu[i].text == "Back " or menu[i].text == "Exit" or menu[i].text == "Quit" then
                term.setTextColor(colors.red)
            elseif menu[i].text == "Crusher " and not isContraptionToggled("crusher") then
                term.setTextColor(colors.red)
            else
                term.setTextColor(colors.lime)
            end
                term.write(" "..menu[i].text)
        else
            term.setCursorPos(termX/2.5, 5+i*2)
            term.setTextColor(colors.gray)
            term.write(menu[i].text)
        end
    end
end

--[[ Handler Methods ]]--

function onKeyPressed(key, menu)
    if key == keys.enter then
       onItemSelected(menu) 
    elseif key == keys.up then
        if selectedItem > 1 then
            selectedItem = selectedItem - 1
        end
    elseif key == keys.down then
        if selectedItem < #menu then
            selectedItem = selectedItem + 1
        end
    end
end

function onItemSelected(menu)
    menu[selectedItem].handler()
end

--[[ Main Method ]]--

function main()
    os.pullEvent = os.pullEventRaw
    while inMainMenu do
    term.clear()
    term.setCursorPos(1,1)
    printMenu(mainMenu)
    
    event, key = os.pullEvent("key")
    onKeyPressed(key,mainMenu)
    end
end

--[[ Run ]]--

main()
