local mod = get_mod("Murmur Hash")

dofile("scripts/mods/Murmur Hash/Murmur Hash bit64")

--[[

    murmur inverse algorythm is based on:
    https://bitsquid.blogspot.com/2011/08/code-snippet-murmur-hash-inverse-pre.html
    https://gitlab.com/lschwiderski/vt2_bundle_unpacker/-/blob/master/src/murmur/murmurhash64.rs?ref_type=heads


    Other 64bit Libraries:
    https://github.com/ManuelBlanc/lua-bit64.git
    https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/47c9523e6f8ebd16b1ee7147f6b6dfcf3cfe4aa5/scripts/utils/sha256.lua#L65


    Notes:
    luajit 2.0 has bit operators: https://bitop.luajit.org/
    luajit can work with up to 53bit values by adding "ull" after hex values
    https://stackoverflow.com/questions/5977654/how-do-i-use-the-bitwise-operator-xor-in-lua
    https://github.com/minetest-mods/turtle/blob/bd7d49f1843c7e35a0e6647ef19bb6b7cae61f3c/bit32.lua#L76


]]

-- create a murmur hash representation of a string
-- as it is used in the game
mod.murmur_hash = function(string)
    return Application.make_hash(string)
end

-- inverse a hash value (hashes have to be split to their hi and lo parts (cut in half))
mod.hash_inverse = function(hash_hi, hash_lo, seed)

    -- define 64bit variables split into 32bit variants
    local M_hi = 0xc6a4a793
    local M_lo = 0x5bd1e995
    local M = i64_ax(M_hi, M_lo)

    local M_INVERSE_hi = 0x5f7a0ea7
    local M_INVERSE_lo = 0xe59b19bd
    local M_INVERSE = i64_ax(M_INVERSE_hi, M_INVERSE_lo)

    local R = 47 -- define normal lua numbers

    if seed then
        seed = i64(seed)
    else
        seed = i64(0) -- 0 is default
    end

    -- algorythm used to create the hashes
    local h = i64_ax(hash_hi, hash_lo)
    
    h = i64_xor(h, i64_rshift(h, R))

    h = i64_mul(h, M_INVERSE)
    h = i64_xor(h, i64_rshift(h, R))
    h = i64_mul(h, M_INVERSE)

    local h_forward = i64_or(seed, i64_mul(M, i64(8)))

    local k = i64_xor(h, h_forward)
    k = i64_mul(k, M_INVERSE)
    k = i64_xor(k, i64_rshift(k, R))
    k = i64_mul(k, M_INVERSE)

    -- swap the endianness of the resulting hash and return
    return k

end

-- get a possible string value from a hash value
-- this value can be used to be fed in to functiones used by the game that
-- need a the name of a ressource etc
mod.get_string_from_hash = function(hash)

    -- check if the hash is 8 Characters long (fake 32bit hash)
    if string.len(hash) == 8 then
        hash = hash .. hash
    end

    return mod.hash_inverse(tonumber(string.sub(hash, 1, 8), 16), tonumber(string.sub(hash, 9, 16), 16))

end

-- get any element in the game, tostring it and use this function to get its name
mod.get_string_from_data = function(data)

    if string.sub(data, 2, 5) == "Unit" then
        return mod.get_string_from_hash(string.sub(data, 12, 27))
    end
    if string.sub(data, 2, 9) == "Material" then
        return mod.get_string_from_hash(string.sub(data, 16, 23))
    end

    mod:echo("Could not find Hash in element: " .. data)

end


-- test commands for use in game
mod:command("murmur_hash", " murmur hash a string", function (hash_test)
    local hash_test = mod.murmur_hash(hash_test)
    mod:echo(hash_test)
end)
mod:command("murmur_inverse", " hash inverse a HEX value", function (hex_number_hi, hex_number_lo)

    if hex_number_hi and hex_number_lo then
    
        local hash_test = mod.hash_inverse(hex_number_hi, hex_number_lo)

        mod:echo("HEX of the hash: " .. i64_toString(hash_test))
        mod:echo("ASCII of the hash: " .. i64_to_slot_name(hash_test))
  
    else
        mod:echo("Error: No hash values provided.")
    end

end)

