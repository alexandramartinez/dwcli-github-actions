import firstWith from dw::core::Arrays
import lines from dw::core::Strings
output application/json
var connections = lines(payload) map ($ splitBy "-") reduce ((item, a={}) -> 
    a update {
        case x at ."$(item[0])"! -> (a[item[0]] default []) + item[1]
        case y at ."$(item[1])"! -> (a[item[1]] default []) + item[0]
    }
)
fun keepChecking(computers, prevComputers=[], sizeOfPrevComputers=0) = do {
    computers map ((computer1) -> (
        if (isEmpty(prevComputers))
            keepChecking(connections[computer1],[computer1],1)
        else if (sizeOfPrevComputers == 1)
            (keepChecking(connections[computer1] - prevComputers[0], prevComputers + computer1, 2)) 
        else do {
            @Lazy
            var filtered = (connections[computer1] - prevComputers[-1]) 
                filter ((computer2) -> prevComputers contains computer2)
            @Lazy
            var sizeMatches = sizeOfPrevComputers-1 == sizeOf(filtered)
            ---
            if (sizeMatches)
                (filtered map ((computer2) ->
                    (keepChecking(connections[computer1] -- prevComputers, prevComputers + computer1, sizeOfPrevComputers+1))
                ))
            else if (sizeOfPrevComputers <= 2) []
            else {
                pc: prevComputers,
                size: sizeOfPrevComputers
            }
        }
    ))
}
fun flattenNestedArrays(data) = data match {
    case is Array -> flatten(data map flattenNestedArrays($))
    else -> data
}
var finalList = flattenNestedArrays(keepChecking(namesOf(connections))) 
var maxsize = max(finalList.size)
---
(finalList firstWith ($.size == maxsize)).pc orderBy $ joinBy ","