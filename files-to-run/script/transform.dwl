import lines from dw::core::Strings
output application/json
var connections = lines(payload) map ($ splitBy "-") reduce ((item, a={}) -> 
    a update {
        case x at ."$(item[0])"! -> (a[item[0]] default []) + item[1]
        case y at ."$(item[1])"! -> (a[item[1]] default []) + item[0]
    }
)
fun keepChecking(computers, prevComputers=[]) =
    (flatten(computers map ((computer1) -> (
        if (isEmpty(prevComputers))
            keepChecking(connections[computer1],[computer1])
        else if (sizeOf(prevComputers) == 1)
            (keepChecking(connections[computer1] - prevComputers[0], prevComputers + computer1)) distinctBy $
        else do {
            @Lazy
            var filtered = (connections[computer1] - prevComputers[-1]) 
                filter ((computer2) -> prevComputers contains computer2)
            @Lazy
            var sizeMatches = sizeOf(prevComputers)-1 == sizeOf(filtered)
            ---
            if (sizeMatches)
                flatten(filtered map ((computer2) ->
                    (keepChecking(connections[computer1] -- prevComputers, prevComputers + computer1)) distinctBy $
                ))
            else ([prevComputers orderBy $])
        }
    ))) distinctBy $)
---
keepChecking(namesOf(connections)) default [] orderBy (-sizeOf($))
then ($[0] joinBy ",")