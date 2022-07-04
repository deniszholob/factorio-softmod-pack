```lua

-- Reveal Map
/c
game.players[1].force.chart(
    game.players[1].surface,
    {
        {game.players[1].position.x - 300, game.players[1].position.y - 300},
        {game.players[1].position.x + 300, game.players[1].position.y + 300}
    }
)

-- Set enemy evolution
/c
game.forces["enemy"].evolution_factor=0.5

-- Print technologies
/c
for i, tech in pairs(game.players[1].force.technologies) do
game.print(tech)
end

--  Write techs to a file
/c local list = {}
for _, tech in pairs(game.player.force.technologies) do
    if tech.research_unit_count_formula then
        list[#list+1] = tech.name .. '\t|\t' .. tech.level .. '\t|\t' .. tech.research_unit_count .. '\t|\t' .. tech.research_unit_count_formula  .. '\t|\t' .. tech.research_unit_energy
    end
end
game.write_file("techs.lua", serpent.block(list) .. "\n", true)

-- Unlock tech research
/c
game.players[1].force.technologies['mining-productivity-16'].researched=true

-- Print research ingredients
/c
game.print(serpent.block(game.players[1].force.technologies['mining-productivity-16'].research_unit_ingredients))


-- Set current research
/c game.players[1].force.current_research = "mining-productivity-16"


```
