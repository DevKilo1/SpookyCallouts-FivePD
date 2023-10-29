local bucketsInUse = {0}
local bucketPasses = {}

find = function(t, value)
    local result = false;
    local finished = false
    for i,v in pairs(t) do
        if v == value then
            result = true
        end
        if i >= #t then
            finished = true
        end
    end
    if #t < 1 then
        finished = true
    end
    repeat Wait(100) until finished
    return result
end

function GetNextUnoccupiedBucket()
    local number = 0;
    while find(bucketsInUse,number) do
        print("Number is busy")
        number = number + 1;
        Wait(100)
    end 
    return number;
end

RegisterNetEvent("KiloMultiverse::CreateNew")
AddEventHandler("KiloMultiverse::CreateNew", function(pass) -- Pass is like randomly generated UUID
    local bucket = GetNextUnoccupiedBucket()
    table.insert(bucketsInUse,bucket)
    bucketPasses[bucket] = pass;
    TriggerClientEvent("KiloMultiverse::CreateNewReturn",-1,pass,bucket)
end)

RegisterNetEvent("KiloMultiverse::DeleteBucket", function(pass, bucket)
    if pass == bucketPasses[bucket] then
        for i,v in pairs(bucketsInUse) do
            if v == bucket then
                table.remove(bucketsInUse,i)
            end
        end
        bucketPasses[bucket] = nil;
    end
end)

RegisterNetEvent("KiloMultiverse::SendPlayerToBucket", function(bucket, playerIndex,pass)
    if bucket ~= 0 and pass ~= bucketPasses[bucket] then return end
    SetPlayerRoutingBucket(playerIndex,bucket)
    print("Sent player to bucket")
end)

RegisterNetEvent("KiloMultiverse::SendEntityToBucket", function(bucket, entityNetId,pass)
    if bucket ~= 0 and pass ~= bucketPasses[bucket] then return end
    local entity = NetworkGetEntityFromNetworkId(entityNetId)
    SetEntityRoutingBucket(entity,bucket)
end)

RegisterNetEvent("KiloMultiverse::SetPopulationInBucket", function(bucket, toggle,pass)
    if pass ~= bucketPasses[bucket] then return end
    if toggle then
        SetRoutingBucketPopulationEnabled(bucket,true)
    else
        SetRoutingBucketPopulationEnabled(bucket,false)
    end
end)