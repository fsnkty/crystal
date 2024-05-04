local mountain = require('mountain.colors')

local theme = {}
theme.loadSyntax = function ()
	local syntax = {
		Type =				{ fg = mountain.shinkai },
		StorageClass =		{ fg = mountain.shinkai },
		Structure =			{ fg = mountain.shinkai },
  	    Constant =			{ fg = mountain.aki },
  	    String =			{ fg = mountain.take },
  	    Character =			{ fg = mountain.take },
		Number =			{ fg = mountain.aki },
		Boolean =			{ fg = mountain.aki },
		Float =				{ fg = mountain.aki },
  	    Statement =			{ fg = mountain.kosumosu },
		Label =				{ fg = mountain.chikyu },
  	    Operator =			{ fg = mountain.mizu },
		Exception =			{ fg = mountain.kaen },
  	    PreProc =			{ fg = mountain.mizu },
		Include =			{ fg = mountain.sora },
		Define =			{ fg = mountain.sora },
		Macro =				{ fg = mountain.sora },
		Typedef =			{ fg = mountain.shinkai },
		PreCondit =			{ fg = mountain.sora },
  	    Special =			{ fg = mountain.kori },
		SpecialChar =		{ fg = mountain.kori },
		Tag =				{ fg = mountain.kori },
		Delimiter =			{ fg = mountain.kori },
		SpecialComment =	{ fg = mountain.kori },
		Debug =				{ fg = mountain.kori },
  	    Underlined =		{ style = 'underline' },
  	    Bold =				{ style = 'bold' },
  	    Italic =			{ style = 'italic' },
		Ignore =			{ fg = mountain.iwa},
  	    Error =				{ fg = mountain.kaen, style = 'bold,underline' },
  	    Todo =				{ fg = mountain.yoru, bg = mountain.suna },
  	    Conceal =			{ fg = mountain.iwa},

  	    -- Markdown and HTML
  	    markdownCodeDelimiter =		{ fg = mountain.amagumo },
  	    markdownCode =			{ fg = mountain.take },
  	    markdownCodeBlock = 		{ fg = mountain.take },
  	    markdownH1= 			{ fg = mountain.sakura, style = "bold" },
  	    markdownH2= 			{ fg = mountain.ajisai, style = "bold" },
  		markdownLinkText = 		{ fg = mountain.ajisai, style = "underline" },
  	    htmlLink =			{ fg = mountain.kusa, style = "underline" },
  	    htmlH1 =			{ fg = mountain.sakura, style = "bold" },
  	    htmlH2 =			{ fg = mountain.ajisai, style = "bold" },

  	    -- Debug
  	    debugPC = 			{ bg = mountain.iwa },
    }
  	syntax.Comment =		{fg = mountain.amagumo, style = "italic" }
	syntax.Conditional =		{fg = mountain.kosumosu}
  	syntax.Keyword =		{fg = mountain.sora}
	syntax.Repeat =			{fg = mountain.chikyu}
	syntax.Function =		{fg = mountain.shinkai}
	syntax.Identifier =		{fg = mountain.sakura};

	return syntax
end

theme.loadEditor = function ()
	local editor = {
		Normal =		{ fg = mountain.yuki, bg = mountain.yoru },
		NormalNC =		{ fg = mountain.yuki, bg = mountain.yoru },
		NormalFloat =	{ fg = mountain.yuki, bg = mountain.yoru },
		FloatBorder =	{ fg = mountain.yuki, bg = mountain.amagumo },
		ColorColumn =	{ fg = mountain.none, bg = mountain.iwa },
		Conceal =    	{ fg = mountain.iwa },
		Cursor =     	{ fg = mountain.yuki, bg = mountain.none, style = 'reverse' },
		CursorIM =   	{ fg = mountain.yuki, bg = mountain.none, style = 'reverse' },
		Directory =  	{ fg = mountain.ajisai },
		DiffAdd =    	{ fg = mountain.kusa, bg = mountain.none, style = 'reverse' },
		DiffChange = 	{ fg = mountain.ajisai, bg = mountain.none, style = 'reverse' },
		DiffDelete = 	{ fg = mountain.ichigo, bg = mountain.none, style = 'reverse' },
		DiffText =   	{ fg = mountain.ume, bg = mountain.none, style = 'reverse' },
		EndOfBuffer =	{ fg = mountain.yoru },
		VertSplit =		{ fg = mountain.iwa },
		ErrorMsg =   	{ fg = mountain.kaen },
		Folded =     	{ fg = mountain.ume, bg = mountain.iwa, style = 'italic' },
	    FoldColumn = 	{ fg = mountain.amagumo, bg = mountain.iwa },
	    SignColumn = 	{ fg = mountain.amagumo, bg = mountain.iwa },
	    SignColumnSB = 	{ fg = mountain.gin, bg = mountain.amagumo },
		Substitute =	{ fg = mountain.iwa, bg = mountain.kaen },
		IncSearch =  	{ fg = mountain.aki, bg = mountain.none, style = 'reverse' },
    	LineNr =     	{ fg = mountain.amagumo },
		CursorLineNr =	{ fg = mountain.okami },
		MatchParen = 	{ bg = mountain.amagumo, style = 'bold' },
		ModeMsg =    	{ fg = mountain.okami, style = 'bold' },
		MoreMsg =    	{ fg = mountain.ume },
		MsgArea =    	{ fg = mountain.okami },
		NonText =    	{ fg = mountain.iwa },
		Pmenu =      	{ fg = mountain.yuki, bg = mountain.iwa },
		PmenuSel =   	{ fg = mountain.yoru, bg = mountain.sakura },
		PmenuSbar =  	{ fg = mountain.yuki, bg = mountain.tetsu },
		PmenuThumb = 	{ fg = mountain.yuki, bg = mountain.amagumo },
		Question =   	{ fg = mountain.ume },
		QuickFixLine =	{ bg = mountain.iwa, style = 'bold' },
		qfLineNr =   	{ fg = mountain.gin, },
		qfFileName =   	{ fg = mountain.ajisai, },
		Search =     	{ fg = mountain.yoru, bg = mountain.shinkai },
		SpecialKey = 	{ fg = mountain.amagumo },
		SpellBad =   	{ sp = mountain.kaen, style = 'undercurl' },
		SpellCap =		{ sp = mountain.suna, style = 'undercurl' },
		SpellLocal =	{ sp = mountain.shinkai, style = 'undercurl' },
		SpellRare =		{ sp = mountain.sora, style = 'undercurl' },
		StatusLine =	{ fg = mountain.kaen, bg = mountain.iwa },
		StatusLineNC =	{ fg = mountain.amagumo, bg = mountain.kesseki },
		Tabline =		{ fg = mountain.yuki, bg = mountain.amagumo },
		TabLineFill =	{ bg = mountain.amagumo },
		TablineSel =	{ fg = mountain.yoru, bg = mountain.sakura },
		Title =			{ fg = mountain.ajisai, style = 'bold' },
		Visual =		{ fg = mountain.none, bg = mountain.iwa },
		VisualNOS =		{ fg = mountain.kaen, bg = mountain.none },
		WarningMsg =	{ fg = mountain.yuyake },
		Whitespace =	{ fg = mountain.amagumo },
		WildMenu =		{ bg = mountain.iwa },
		CursorColumn =	{ fg = mountain.none, bg = mountain.iwa},
		CursorLine =	{ fg = mountain.none, bg = mountain.kesseki},
	}
	return editor
end

theme.loadTerminal = function ()
	vim.g.terminal_color_0 = mountain.amagumo
	vim.g.terminal_color_1 = mountain.kaen
	vim.g.terminal_color_2 = mountain.take
	vim.g.terminal_color_3 = mountain.chikyu
	vim.g.terminal_color_4 = mountain.ume
	vim.g.terminal_color_5 = mountain.kosumosu
	vim.g.terminal_color_6 = mountain.mizu
	vim.g.terminal_color_7 = mountain.yuki
	vim.g.terminal_color_8 = mountain.iwa
	vim.g.terminal_color_9 = mountain.ichigo
	vim.g.terminal_color_10 = mountain.kusa
	vim.g.terminal_color_11 = mountain.suna
	vim.g.terminal_color_12 = mountain.ajisai
	vim.g.terminal_color_13 = mountain.sakura
	vim.g.terminal_color_14 = mountain.sora
	vim.g.terminal_color_15 = mountain.usagi
end

theme.loadTreeSitter = function ()
	local treesitter = {
		TSNote =			{ fg = mountain.yoru, bg = mountain.sora },
		TSWarning =			{ fg = mountain.yoru, bg = mountain.yuyake },
		TSDanger =			{ fg = mountain.yoru, bg = mountain.ichigo },
		TSAnnotation =		{ fg = mountain.suna },
		TSCharacter =		{ fg = mountain.kusa },
  	    TSConstructor =		{ fg = mountain.sakura },
		TSConstant =		{ fg = mountain.yuyake },
		TSFloat =			{ fg = mountain.sakura },
		TSNumber =			{ fg = mountain.sakura },
		TSString =			{ fg = mountain.kusa },
		TSAttribute =		{ fg = mountain.sakura },
		TSBoolean =			{ fg = mountain.sora },
		TSConstBuiltin =	{ fg = mountain.ajisai },
		TSConstMacro =		{ fg = mountain.ajisai },
		TSError =			{ fg = mountain.kaen }, 
		TSException =		{ fg = mountain.sakura },
  	    TSField =			{ fg = mountain.sora },
		TSFuncMacro =		{ fg = mountain.ajisai },
		TSInclude =			{ fg = mountain.sora },
  	    TSLabel =			{ fg = mountain.ajisai },
		TSNamespace =		{ fg = mountain.gin},
  	    TSOperator =		{ fg = mountain.sora },
  	    TSParameter =		{ fg = mountain.suna },
		TSParameterReference = { fg = mountain.suna },
  	    TSProperty =		{ fg = mountain.sora },
  	    TSPunctDelimiter =	{ fg = mountain.sora },
  	    TSPunctBracket =	{ fg = mountain.okami },
  	    TSPunctSpecial =	{ fg = mountain.sora },
  	    TSStringRegex =		{ fg = mountain.ajisai },
  	    TSStringEscape =	{ fg = mountain.sakura },
		TSSymbol =			{ fg = mountain.kosumosu },
		TSType =			{ fg = mountain.shinkai},
		TSTypeBuiltin =		{ fg = mountain.shinkai},
		TSTag =				{ fg = mountain.mizu },
		TSTagDelimiter =	{ fg = mountain.ume },
		TSText =			{ fg = mountain.yuki },
  	    TSTextReference =	{ fg = mountain.kusa },
		TSEmphasis =		{ fg = mountain.ume },
		TSUnderline =		{ fg = mountain.yuki, bg = mountain.none, style = 'underline' },
		TSStrike =			{ },
		TSTitle =			{ fg = mountain.ume, bg = mountain.none, style = 'bold' },
		TSLiteral =			{ fg = mountain.yuki },
		TSURI =				{ fg = mountain.take },
	}

	treesitter.TSComment=          	{ fg = mountain.amagumo }
	treesitter.TSConditional =    	{ fg = mountain.shinkai }
    treesitter.TSKeyword =         	{ fg = mountain.sakura }
	treesitter.TSRepeat =          	{ fg = mountain.shinkai }
    treesitter.TSKeywordFunction = 	{ fg = mountain.sakura }
	treesitter.TSFunction =        	{ fg = mountain.mizu }
	treesitter.TSMethod =          	{ fg = mountain.ume }
	treesitter.TSFuncBuiltin =     	{ fg = mountain.mizu }
	treesitter.TSVariable =        	{ fg = mountain.yuki }
	treesitter.TSVariableBuiltin = 	{ fg = mountain.ichigo }
	return treesitter
end

theme.loadLSP = function ()
	local lsp = {
		LspDiagnosticsDefaultError =		{ fg = mountain.kaen },
		LspDiagnosticsSignError =			{ fg = mountain.kaen },
		LspDiagnosticsFloatingError =		{ fg = mountain.kaen },
		LspDiagnosticsVirtualTextError =	{ fg = mountain.kaen },
		LspDiagnosticsUnderlineError =		{ style = 'undercurl', sp = mountain.kaen },
		LspDiagnosticsDefaultWarning =		{ fg = mountain.sakura},
		LspDiagnosticsSignWarning =			{ fg = mountain.sakura},
		LspDiagnosticsFloatingWarning =		{ fg = mountain.sakura},
		LspDiagnosticsVirtualTextWarning =	{ fg = mountain.sakura},
		LspDiagnosticsUnderlineWarning =	{ style = 'undercurl', sp = mountain.sakura },
		LspDiagnosticsDefaultInformation =	{ fg = mountain.suna },
		LspDiagnosticsSignInformation =		{ fg = mountain.suna },

		LspDiagnosticsFloatingInformation =		{ fg = mountain.ume },
		LspDiagnosticsVirtualTextInformation =	{ fg = mountain.ume },
		LspDiagnosticsUnderlineInformation =	{ style = 'undercurl', sp = mountain.ume },
		LspDiagnosticsDefaultHint =			{ fg = mountain.shinkai  },
		LspDiagnosticsSignHint =			{ fg = mountain.shinkai  },
		LspDiagnosticsFloatingHint =		{ fg = mountain.shinkai  },
		LspDiagnosticsVirtualTextHint =		{ fg = mountain.shinkai  },
		LspDiagnosticsUnderlineHint =		{ style = 'undercurl', sp = mountain.ume },
		LspReferenceText =				{ fg = mountain.yuki, bg = mountain.tsuki },
		LspReferenceRead =				{ fg = mountain.yuki, bg = mountain.tsuki },
		LspReferenceWrite =				{ fg = mountain.yuki, bg = mountain.tsuki },
	}
	return lsp
end

theme.loadPlugins = function()
	local plugins = {
		-- Telescope
		TelescopePromptBorder =		{ fg = mountain.amagumo },
		TelescopeResultsBorder =	{ fg = mountain.amagumo },
		TelescopePreviewBorder =	{ fg = mountain.amagumo },
		TelescopeSelectionCaret =	{ fg = mountain.sakura },
		TelescopeSelection =		{ bg = mountain.amagumo },
		TelescopeMatching =			{ fg = mountain.sakura },
		TelescopeNormal =			{ fg = mountain.yuki, bg = mountain.yoru },		
		-- NvimTree
		NvimTreeRootFolder =		{ fg = mountain.sora, style = "bold" },
		NvimTreeGitDirty =			{ fg = mountain.sakura },
		NvimTreeGitNew =			{ fg = mountain.kusa },
		NvimTreeImageFile =			{ fg = mountain.sakura },
		NvimTreeExecFile =			{ fg = mountain.kusa },
		NvimTreeSpecialFile =		{ fg = mountain.kori , style = "underline" },
		NvimTreeFolderName =		{ fg = mountain.suna },
		NvimTreeEmptyFolderName =	{ fg = mountain.kesseki },
		NvimTreeFolderIcon =		{ fg = mountain.gin },
		NvimTreeIndentMarker =		{ fg  = mountain.kesseki },
		LspDiagnosticsError =		{ fg = mountain.kaen },
		LspDiagnosticsWarning =		{ fg = mountain.sakura },
		LspDiagnosticsInformation =	{ fg = mountain.suna },
		LspDiagnosticsHint =		{ fg = mountain.kori },
		-- BufferLine
		BufferLineIndicatorSelected =	{ fg = mountain.yoru },
		BufferLineFill =			    { bg = mountain.yoru },
		-- Indent Blankline
		IndentBlanklineChar =		 { fg = mountain.amagumo },
		IndentBlanklineContextChar = { fg = mountain.amagumo },
		-- Neovim
    	healthError = 	{ fg = mountain.ichigo },
    	healthSuccess = { fg = mountain.kusa },
    	healthWarning = { fg = mountain.yuyake },
	}
	return plugins
end

return theme
