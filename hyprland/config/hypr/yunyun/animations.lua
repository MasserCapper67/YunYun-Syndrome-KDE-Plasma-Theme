-- Short and snappy, the KDE theme has animations turned off entirely

hl.curve("yyPop",    { type = "bezier", points = { {0.2, 0.9}, {0.1, 1.05} } })
hl.curve("yyLinear", { type = "bezier", points = { {0, 0},     {1, 1}      } })

hl.animation({ leaf = "global",     enabled = true, speed = 3, bezier = "yyPop" })
hl.animation({ leaf = "windows",    enabled = true, speed = 3, bezier = "yyPop", style = "popin 90%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 2, bezier = "yyLinear" })
hl.animation({ leaf = "border",     enabled = true, speed = 4, bezier = "yyLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "yyPop", style = "slide" })
