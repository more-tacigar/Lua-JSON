# Lua-json is a simple JSON parser written in Lua.

Lua-jsonはLuaで書かれたシンプルなJSONパーサです。  
JSONファイルを読み込んでLuaのテーブル構造に落とし込みます。  

## 使い方

パスの通った場所に置いて`require`して`parse`するだけです。  

```lua
local Json = require("json")
local res = Json.parse("hoge.json")
```
