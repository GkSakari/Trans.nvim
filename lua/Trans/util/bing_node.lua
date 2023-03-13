--- INFO : Generated by newbing

-- 基类node
local Node = {}
Node.__index = Node

-- 构造函数
function Node:new(row, col, width, height)
    local obj = {
        row = row,
        col = col,
        width = width,
        height = height,
    }
    setmetatable(obj, self)
    return obj
end

-- 渲染方法（空实现）
function Node:render()
end

-- 更新方法（空实现）
function Node:update()
end

-- 子类box node
local BoxNode = setmetatable({}, Node)
BoxNode.__index = BoxNode

-- 构造函数
function BoxNode:new(row, col, width, height, border_style)
    local obj = Node.new(self, row, col, width, height)
    obj.border_style = border_style or "single"
    return obj
end

-- 渲染方法（画边框）
function BoxNode:render()
    local top_left_char =
        self.border_style == "single" and "┌" or self.border_style == "double" and "╔"
    local top_right_char =
        self.border_style == "single" and "┐" or self.border_style == "double" and "╗"
    local bottom_left_char =
        self.border_style == "single" and "└" or self.border_style == "double" and "╚"
    local bottom_right_char =
        self.border_style == "single" and "┘" or self.border_style == "double" and "╝"
    local horizontal_char =
        self.border_style == "single" and "-" or self.border_style == "double" and "="
    local vertical_char =
        self.border_style == "single" and "|" or self.border_style == "double" and "|"

    -- draw top line
    vim.api.nvim_buf_set_text(
        vim.api.nvim_get_current_buf(),
        self.row,
        self.col,
        self.row,
        math.min(self.col + self.width - 1),
        { top_left_char .. horizontal_char:rep(self.width - 2) .. top_right_char }
    )

    -- draw bottom line
    vim.api.nvim_buf_set_text(
        vim.api.nvim_get_current_buf(),
        math.min(self.row + self.height - 1),
        math.max(self.col),
        math.min(self.row + self.height - 1),
        math.min(self.col + self.width - 1),
        { bottom_left_char .. horizontal_char:rep(self.width - 2) .. bottom_right_char }
    )

    -- draw left line
    for i = self.row + 1, self.row + self.height - 2 do
        vim.api.nvim_buf_set_text(
            vim.api.nvim_get_current_buf(),
            i,
            math.max(self.col),
            i,
            math.max(self.col + 1),
            { vertical_char }
        )
    end

    -- draw right line
    for i = self.row + 1, self.row + self.height - 2 do
        vim.api.nvim_buf_set_text(
            vim.api.nvim_get_current_buf(),
            i,
            math.min(self.col + self.width - 1),
            i,
            math.min(self.col + self.width),
            { vertical_char }
        )
    end
end

-- 更新方法（暂无）

-- 子类text node
local TextNode = setmetatable({}, Node)
TextNode.__index = TextNode

-- 构造函数
function TextNode:new(row, col, width, height, text_content)
    local obj = Node.new(self, row, col, width, height)
    obj.text_content = text_content or ""
    return obj
end

-- 渲染方法（写入文本内容）
function TextNode:render()
    -- split text content by newline character
    local lines = vim.split(obj.text_content, "\n")

    -- write each line to buffer text within the node boundaries
    for i, line in ipairs(lines) do
        if i <= self.height then
            vim.api.nvim_buf_set_text(
                vim.api.nvim_get_current_buf(),
                math.min(self.row + i - 1), math.max(self.col),
                math.min(self.row + i - 1),
                math.min(self.col + self.width - 1),
                { line:sub(1, self.width) }
            )
        end
    end
end

-- 更新方法（暂无）

-- 子类extmark node
local ExtmarkNode = setmetatable({}, Node)
ExtmarkNode.__index = ExtmarkNode

-- 构造函数
function ExtmarkNode:new(row, col, width, height, hl_group)
    local obj = Node.new(self, row, col, width, height)
    obj.hl_group = hl_group or "Normal"
    return obj
end

-- 渲染方法（创建一个extmark）
function ExtmarkNode:render()
    -- create a namespace for extmarks
    local ns = vim.api.nvim_create_namespace("nodes")

    -- create an extmark with the given highlight group and position
    vim.api.nvim_buf_set_extmark(
        vim.api.nvim_get_current_buf(),
        ns,
        self.row,
        self.col,
        { hl_group = self.hl_group, end_line = self.row + self.height - 1, end_col = self.col + self.width - 1 }
    )
end

-- 更新方法（暂无）

-- 返回所有的节点类
return {
    Node = Node,
    BoxNode = BoxNode,
    TextNode = TextNode,
    ExtmarkNode = ExtmarkNode,
}
