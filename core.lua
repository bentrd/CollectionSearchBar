G.ARGS = {collection_search_input = ''}

G.FUNCS.search_bar = function ()
    local search_bar = {n = G.UIT.R, config = { align = 'cm', padding = 0.2 }, nodes = {
        create_text_input({ prompt_text = 'Search for jokers or consumables', max_length = 32, ref_table = G.ARGS, ref_value = 'collection_search_input', extended_corpus = true, w = 6 }),
        {n = G.UIT.C, config = { id = 'your_collection_search', align = 'cm', maxw = 1, r = 0.1, hover = true, colour = G.C.RED, button = 'your_collection_search', shadow = true }, nodes = {
            {n = G.UIT.R, config = { align = 'cm', padding = 0.1, no_fill = true }, nodes = {
                {n = G.UIT.T, config = { id = 'your_collection_search', text = 'Search', scale = 0.5, colour = G.C.UI.TEXT_LIGHT, shadow = true } }
            }}
        }}
    }}
    return search_bar
end

function get_matched_items()
    local matched_items = {}
    local search_input = string.lower(G.ARGS['collection_search_input'])
    local pools = {"Joker", "Tarot", "Spectral", "Planet"}

    for _, pool in ipairs(pools) do
        for _, v in ipairs(G.P_CENTER_POOLS[pool]) do
            if string.find(string.lower(v.name), search_input) then
                table.insert(matched_items, v)
            end
        end
    end
    return matched_items
end

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
            {n = G.UIT.R,config = { align = "cm", padding = 0.07, no_fill = true },nodes = {
                {n = G.UIT.O, config = { object = G.your_collection[j] }}
            }}
        )
    end

    local matched_items = get_matched_items()

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
    if not args or not args.cycle_config then return end

    local matched_items = get_matched_items()
    
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