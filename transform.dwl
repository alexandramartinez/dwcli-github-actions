import some from dw::core::Arrays
output application/json
var lines = payload splitBy "\n"
var sizeOfLine = sizeOf(lines[0])
fun getChar(x:Number,y:Number):String = if ((x<0) or (y<0)) "" else (lines[y][x] default "")
fun distanceBetween(point1, point2):Number = abs(point1.x - point2.x) + abs(point1.y - point2.y)
fun getRegions(data, result=[]) = (
    data match {
        case [head ~ tail] -> do {
            @Lazy
            var samePlants = result filter (head.plant == $.plant)
            @Lazy
            var isCloseEnough = (flatten(samePlants.debug) contains head.coords)
                or ((head.coords.y - max(flatten(samePlants.debug).y) <= 1))
            ---
            if (isEmpty(samePlants)) getRegions(tail, result + {(head), region:1})
            else getRegions(tail, result + {
                (head),
                region: if (isCloseEnough) samePlants[-1].region
                    else samePlants[-1].region + 1,
            })
        }
        case [] -> result
    }
)
var list = flatten(lines map ((line, y) -> 
    (line splitBy "") map ((plant, x) -> do {
        var p = (if (plant == getChar(x-1,y)) 0 else 1)
            + (if (plant == getChar(x+1,y)) 0 else 1)
            + (if (plant == getChar(x,y-1)) 0 else 1)
            + (if (plant == getChar(x,y+1)) 0 else 1)
        ---
        {
            plant: if (p != 4) plant else "$plant-$(uuid())",
            area: 1,
            perimeter: p,
            coords: {
                x: x,
                y: y
            },
            // index: (sizeOfLine*y)+x+1
        }
    })
))
var list2 = list map ((item, index) -> 
    {
        (item),
        debug: ((list filter ($.plant == item.plant)).coords 
            filter (($ distanceBetween item.coords) <= 1))
    }
)
---
list2
groupBy $.plant mapObject ((value, key, index) -> 
    (key): getRegions(value) groupBy $.region mapObject ((value, key, index) -> 
        (key): {
            area: sum(value.area),
            perimeter: sum(value.perimeter),
            total: sum(value.area) * sum(value.perimeter)
        }
    )
) then $..total then sum($)