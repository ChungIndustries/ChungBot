require("lib/apis/class")

local floor = math.floor


PriorityQueue = Class()

function PriorityQueue:__init()
    self.heap = {}
    self.size = 0
end


function PriorityQueue:empty()
    return self.size == 0
end


function PriorityQueue:parent(i)
    if i == 1 then
        return 1
    else
        return floor(i / 2)
    end
end


function PriorityQueue:left(i)
    return 2*i
end


function PriorityQueue:right(i)
    return 2*i + 1
end


function PriorityQueue:swap(i, j)
    self.heap[i], self.heap[j] = self.heap[j], self.heap[i]
end


function PriorityQueue:heapify_up(i)
    if i > 1 and self.heap[self:parent(i)].priority < self.heap[i].priority then
        self:swap(i, self:parent(i))
        self:heapify_up(self:parent(i))
    end
end


function PriorityQueue:heapify_down(i)
    local left = self:left(i);
    local right = self:right(i);
    local largest = i;

    if left <= self.size and self.heap[left].priority > self.heap[largest].priority then
        largest = left;
    end

    if right <= self.size and self.heap[right].priority > self.heap[largest].priority then
        largest = right;
    end

    if largest ~= i then
        self:swap(i, largest);
        self:heapify_down(largest);
    end

end


function PriorityQueue:put(element, priority)
    self.heap[self.size + 1] = {item=element, priority=priority}
    self.size = self.size + 1
    self:heapify_up(self.size)
end


function PriorityQueue:pop()
    local ret = self.heap[1][1]

    self.heap[1] = self.heap[self.size]
    table.remove(self.heap, self.size)
    self.size = self.size - 1
    self:heapify_down(1)

    return ret
end


function PriorityQueue:peek()
    return self.heap[1].item
end


function PriorityQueue:print()
    local function recur(current)
        if current <= self.size then
            print(tostring(self.heap[current].item).." "..tostring(self.heap[current].priority))
            recur(self:left(current))
            recur(self:right(current))
        end
    end

    recur(1)
end
