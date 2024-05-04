-- Copyright (c) 2020-2021 lokesh-krishna
-- MIT license, see LICENSE for more details.

local colors = {
	ajisai	=	'#a39ec4',
	sakura	=	'#c49ec4',
	suna	=	'#c4c19e',
	ichigo	=	'#c49ea0',
	yuyake	=	'#ceb188',
	sora 	=	'#9ec3c4',
	kusa	=	'#9ec49f',
	amagumo	=	'#4c4c4c',
	yuki 	=	'#f0f0f0',
	yoru	= 	'#0f0f0f',
	kori	= 	'#a5b4cb',
	iwa 	= 	'#262626',
}

return {
	normal = {
		a = {fg = colors.yoru, bg = colors.sakura, gui = 'bold'},
		b = {fg = colors.yuki, bg = colors.amagumo},
		c = {fg = colors.yuki, bg = colors.iwa},
		x = {fg = colors.yuki, bg = colors.iwa},
		y = {fg = colors.yuki, bg = colors.amagumo},
		z = {fg = colors.yoru, bg = colors.sakura},
	},
	insert = {
		a = {fg = colors.yoru, bg = colors.sora, gui = 'bold'},
		b = {fg = colors.yuki, bg = colors.amagumo},
		c = {fg = colors.yuki, bg = colors.iwa},
		x = {fg = colors.yuki, bg = colors.iwa},
		y = {fg = colors.yuki, bg = colors.amagumo},
		z = {fg = colors.yoru, bg = colors.sora},
	},
	visual = {
		a = {fg = colors.yoru, bg = colors.ajisai, gui = 'bold'},
		b = {fg = colors.yuki, bg = colors.amagumo},
		c = {fg = colors.yuki, bg = colors.iwa},
		x = {fg = colors.yuki, bg = colors.iwa},
		y = {fg = colors.yuki, bg = colors.amagumo},
		z = {fg = colors.yoru, bg = colors.ajisai},
	},
	replace = {
		a = {fg = colors.yoru, bg = colors.ichigo, gui = 'bold'},
		b = {fg = colors.yuki, bg = colors.amagumo},
		c = {fg = colors.yuki, bg = colors.iwa},
		x = {fg = colors.yuki, bg = colors.iwa},
		y = {fg = colors.yuki, bg = colors.amagumo},
		z = {fg = colors.yoru, bg = colors.ichigo},
	},
	inactive = {
		a = {fg = colors.yuki, bg = colors.amagumo, gui = 'bold'},
		b = {fg = colors.yuki, bg = colors.amagumo},
		c = {fg = colors.yuki, bg = colors.iwa},
		x = {fg = colors.yuki, bg = colors.iwa},
    	y = {fg = colors.yuki, bg = colors.amagumo},
		z = {fg = colors.yuki, bg = colors.amagumo},
  	}
}

