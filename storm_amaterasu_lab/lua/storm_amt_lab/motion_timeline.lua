-- Positions/transforms interpolate between measured samples. Atlas coordinates
-- always select original keys; they never blend across unrelated atlas cells.
local T={}
local function mix(a,b,t)
    local out={} for i=1,#a do out[i]=a[i]+(b[i]-a[i])*t end return out
end
function T.evaluate(data,time)
    local snapshots=data.snapshots
    local left=1
    while left<#snapshots and snapshots[left+1].time<=time do left=left+1 end
    local a=snapshots[left]
    local b=snapshots[math.min(left+1,#snapshots)]
    local fraction=b.time>a.time and math.max(0,math.min(1,(time-a.time)/(b.time-a.time))) or 0
    local byId={}
    for _,s in ipairs(b.states) do byId[s.track]=s end
    local out={} local seen={}
    local function add(sa,sb,weight)
        if weight<=0 then return end
        local s=sa or sb local entry={model=s.model,resource=s.resource,track=s.track,weight=weight}
        if sa and sb then
            for _,name in ipairs({"origin","basis","tint","uvScale","scroll"}) do entry[name]=mix(sa[name],sb[name],fraction) end
            for _,name in ipairs({"film","threshold","opacity","key"}) do entry[name]=sa[name]+(sb[name]-sa[name])*fraction end
        else
            for _,name in ipairs({"origin","basis","tint","uvScale","scroll","film","threshold","opacity","key"}) do entry[name]=s[name] end
        end
        entry.key=math.max(0,math.min(#data.billboards[s.resource]-1,math.floor(entry.key+1e-6)))
        entry.uv=data.billboards[s.resource][entry.key+1]
        out[#out+1]=entry
    end
    for _,sa in ipairs(a.states) do
        local sb=byId[sa.track] seen[sa.track]=true
        add(sa,sb,sb and 1 or 1-fraction)
    end
    for _,sb in ipairs(b.states) do if not seen[sb.track] then add(nil,sb,fraction) end end
    return out,left,fraction
end
return T
