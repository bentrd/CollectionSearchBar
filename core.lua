G.ARGS = {collection_search_input = ''}

-- local create_UIBox_your_collection_ref = create_UIBox_your_collection
-- function create_UIBox_your_collection()
--     local t = create_UIBox_your_collection_ref()
--     local contents = t.nodes[1].nodes[1].nodes[1]
--     local back_btn = t.nodes[1].nodes[1].nodes[2]

--     t.nodes[1].nodes[1].nodes[1] = {n = G.UIT.R, config = { align = "cm", minw = 2.5, padding = 0, r = 0.1 }, nodes = {
--         {n = G.UIT.C, config = { align = "cm", padding = 0 }, nodes = {
--             create_text_input({ all_caps = true, ref_table = G.ARGS, collection_search_ref_value = 'input', extended_corpus = true }),
--         }},
--         {n = G.UIT.C, config = { id = 'your_collection_search', align = "cm", maxw = 1, padding = 0.1, r = 0.1, hover = true, colour = G.C.RED, button = 'your_collection_search', shadow = true }, nodes = {
--             {n = G.UIT.R, config = { align = "cm", padding = 0, no_fill = true }, nodes = {
--                 {n = G.UIT.T, config = { id = 'your_collection_search', text = 'Search', scale = 0.5, colour = G.C.UI.TEXT_LIGHT, shadow = true } }
--             }}
--         }}
--     }}

--     t.nodes[1].nodes[1].nodes[2] = contents
--     t.nodes[1].nodes[1].nodes[3] = back_btn

--     return t
-- end

function create_UIBox_your_collection_search()
    local deck_tables = {}

    G.your_collection = {}
    for j = 1, 3 do
        G.your_collection[j] = CardArea(
            G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
            5 * G.CARD_W,
            0.95 * G.CARD_H,
            { card_limit = 5, type = 'title', highlight_limit = 0, collection = true })
        table.insert(deck_tables,
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.07, no_fill = true },
                nodes = {
                    { n = G.UIT.O, config = { object = G.your_collection[j] } }
                }
            }
        )
    end

    local matched_items = {}
    for _, v in ipairs(G.P_CENTER_POOLS["Joker"]) do
        if string.find(string.lower(v.name), string.lower(G.ARGS['collection_search_input'])) then
            table.insert(matched_items, v)
        end
    end
    for _, v in ipairs(G.P_CENTER_POOLS["Tarot"]) do
        if string.find(string.lower(v.name), string.lower(G.ARGS['collection_search_input'])) then
            table.insert(matched_items, v)
        end
    end
    for _, v in ipairs(G.P_CENTER_POOLS["Spectral"]) do
        if string.find(string.lower(v.name), string.lower(G.ARGS['collection_search_input'])) then
            table.insert(matched_items, v)
        end
    end
    for _, v in ipairs(G.P_CENTER_POOLS["Planet"]) do
        if string.find(string.lower(v.name), string.lower(G.ARGS['collection_search_input'])) then
            table.insert(matched_items, v)
        end
    end

    local options = {}
    for i = 1, math.ceil(#matched_items / (5 * #G.your_collection)) do
        table.insert(options, localize('k_page') .. ' ' .. tostring(i) .. '/' .. tostring(math.ceil(#matched_items / (5 * #G.your_collection))))
    end
    if not options[1] then options = { localize('k_page') .. ' 1/1' } end

    for i = 1, 5 do
        for j = 1, #G.your_collection do
            if i + (j - 1) * 5 > #matched_items then break end
            local center = matched_items[i + (j - 1) * 5]
            local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w / 2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, nil, center)
            if card.set == 'Joker' then card.sticker = get_joker_win_sticker(center)
            else card:start_materialize(nil, i>1 or j>1) end
            G.your_collection[j]:emplace(card)
        end
    end

    INIT_COLLECTION_CARD_ALERTS()

    local t = create_UIBox_generic_options({
        back_func = 'your_collection',
        contents = {
            { n = G.UIT.R, config = { align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05 }, nodes = deck_tables },
            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = {
                    create_option_cycle({ options = options, w = 4.5, cycle_shoulders = true, opt_callback =
                    'your_collection_search_page', current_option = 1, colour = G.C.RED, no_pips = true, focus_args = { snap_to = true, nav = 'wide' } })
                }
            }
        }
    })
    return t
end

---@param args {cycle_config: table}
--**cycle_config** Is the config table from the original option cycle UIE
G.FUNCS.your_collection_search_page = function(args)
    local matched_items = {}
    for _, v in ipairs(G.P_CENTER_POOLS["Joker"]) do
        if string.find(string.lower(v.name), string.lower(G.ARGS['collection_search_input'])) then
            table.insert(matched_items, v)
        end
    end
    for _, v in ipairs(G.P_CENTER_POOLS["Tarot"]) do
        if string.find(string.lower(v.name), string.lower(G.ARGS['collection_search_input'])) then
            table.insert(matched_items, v)
        end
    end
    for _, v in ipairs(G.P_CENTER_POOLS["Spectral"]) do
        if string.find(string.lower(v.name), string.lower(G.ARGS['collection_search_input'])) then
            table.insert(matched_items, v)
        end
    end
    for _, v in ipairs(G.P_CENTER_POOLS["Planet"]) do
        if string.find(string.lower(v.name), string.lower(G.ARGS['collection_search_input'])) then
            table.insert(matched_items, v)
        end
    end
    if not args or not args.cycle_config then return end
    for j = 1, #G.your_collection do
        for i = #G.your_collection[j].cards, 1, -1 do
            local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
            c:remove()
            c = nil
        end
    end
    for i = 1, 5 do
        for j = 1, #G.your_collection do
            local center = matched_items[i + (j - 1) * 5 + (5 * #G.your_collection * (args.cycle_config.current_option - 1))]
            if not center then break end
            local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w / 2, G.your_collection[j].T.y, G
            .CARD_W, G.CARD_H, G.P_CARDS.empty, center)
            if card.set == 'Joker' then card.sticker = get_joker_win_sticker(center)
            else card:start_materialize(nil, i>1 or j>1) end
            G.your_collection[j]:emplace(card)
        end
    end
    INIT_COLLECTION_CARD_ALERTS()
end

G.FUNCS.your_collection_search = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu {
        definition = create_UIBox_your_collection_search(),
    }
end

--[[
 {n=G.UIT.R, config={align = "m", padding = 0.05}, nodes = {
            create_text_input({prompt_text = 'Joker key', ref_table = G, ref_value = 'ARGS_icollection_search_nput', text_scale = 0.3, w = 5, h = 0.6})
        }},
        {n=G.UIT.C, config={align = "cm", padding = 0.15}, nodes={
            UIBox_button({button = 'your_collection_jokers', label = {localize('b_jokers')}, count = G.DISCOVER_TALLIES.jokers,  minw = 5, minh = 1.7, scale = 0.6, id = 'your_collection_jokers'}),
            UIBox_button({button = 'your_collection_decks', label = {localize('b_decks')}, count = G.DISCOVER_TALLIES.backs, minw = 5}),
            UIBox_button({button = 'your_collection_vouchers', label = {localize('b_vouchers')}, count = G.DISCOVER_TALLIES.vouchers, minw = 5, id = 'your_collection_vouchers'}),
            {n=G.UIT.R, config={align = "cm", padding = 0.1, r=0.2, colour = G.C.BLACK}, nodes={
                {n=G.UIT.C, config={align = "cm", maxh=2.9}, nodes={
                {n=G.UIT.T, config={text = localize('k_cap_consumables'), scale = 0.45, colour = G.C.L_BLACK, vert = true, maxh=2.2}},
                }},
                {n=G.UIT.C, config={align = "cm", padding = 0.15}, nodes={
                UIBox_button({button = 'your_collection_tarots', label = {localize('b_tarot_cards')}, count = G.DISCOVER_TALLIES.tarots, minw = 4, id = 'your_collection_tarots', colour = G.C.SECONDARY_SET.Tarot}),
                UIBox_button({button = 'your_collection_planets', label = {localize('b_planet_cards')}, count = G.DISCOVER_TALLIES.planets, minw = 4, id = 'your_collection_planets', colour = G.C.SECONDARY_SET.Planet}),
                UIBox_button({button = 'your_collection_spectrals', label = {localize('b_spectral_cards')}, count = G.DISCOVER_TALLIES.spectrals, minw = 4, id = 'your_collection_spectrals', colour = G.C.SECONDARY_SET.Spectral}),
                }}
            }},
        }},
        {n=G.UIT.C, config={align = "cm", padding = 0.15}, nodes={
            UIBox_button({button = 'your_collection_enhancements', label = {localize('b_enhanced_cards')}, minw = 5}),
            UIBox_button({button = 'your_collection_seals', label = {localize('b_seals')}, minw = 5, id = 'your_collection_seals'}),
            UIBox_button({button = 'your_collection_editions', label = {localize('b_editions')}, count = G.DISCOVER_TALLIES.editions, minw = 5, id = 'your_collection_editions'}),
            UIBox_button({button = 'your_collection_boosters', label = {localize('b_booster_packs')}, count = G.DISCOVER_TALLIES.boosters, minw = 5, id = 'your_collection_boosters'}),
            UIBox_button({button = 'your_collection_tags', label = {localize('b_tags')}, count = G.DISCOVER_TALLIES.tags, minw = 5, id = 'your_collection_tags'}),
            UIBox_button({button = 'your_collection_blinds', label = {localize('b_blinds')}, count = G.DISCOVER_TALLIES.blinds, minw = 5, minh = 2.0, id = 'your_collection_blinds', focus_args = {snap_to = true}}),
        }},

    }})
]]