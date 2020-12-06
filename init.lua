local m = {
	['go'] = {
		[function () return true end] = {
			'type%s+[A-Za-z]',
			'func%s+[A-Za-z]',
			'^\t[A-Z]',
			'^\t[^=]+='
		}
	},
	['lua'] = {
		[function () return true end] = {
			'^function ',
			'^local '
		}
	},
	['makefile'] = {
		[function () return true end] = {
			'^[a-zA-Z0-9/]+:' -- targets
		}
	},
	['yaml'] = {
		[function (file) return string.match(file.name, 'docker%-compose') end] = {
			'^  [a-zA-Z0-9/-]+:' -- two space prefix
		},
		[function () return true end] = {
			'^  [A-Z]%a*:$', -- definitions, parameters
			'^  /[^:]+:$' -- paths
		}
	},
	['markdown'] = {
		[function (file) return string.match(file.name, 'CHANGELOG') end] = {
			'^##%s+' -- H2
		},
		[function () return true end] = {
			'^#+%s+' -- any header
		}
	},
	['ini'] = {
		[function () return true end] = {
			'^%[[^]]+%]$'
		}
	}
}

local info = function (cmd, fmt, ...)
	vis:info(
		string.format(
			'vis-fzf-outline: [%s] %s',
			cmd,
			string.format(fmt, ...)
		)
	)
end

vis:command_register('outline', function (argv,force,win,selection,range)
	local matchers = m[win.syntax]
	if matchers ~= nil and type(matchers) == 'table' then
		for k, v in pairs(matchers) do
			if k(win.file) then
				local matching_lines = {}

				for i, line in ipairs(win.file.lines) do
					for _, pattern in ipairs(v) do
						if string.match(line, pattern) then
							table.insert(matching_lines, string.format(
								'%-5d %s', i, line
							))
							break
						end
					end
				end

				if #matching_lines == 0 then
					info('outline', 'no matching lines')
					return true
				end

				local fzf = io.popen(string.format(
					"echo '%s' | fzf --no-sort --tac",
					table.concat(matching_lines, '\n')
				))
				local out = fzf:read()
				local success, msg, status = fzf:close()

				if status == 0 then
					local line_number = string.match(out, '^(%d+)%s+')
					if line_number ~= nil then
						selection:to(line_number, 1)
					end
				elseif status ~= 130 then -- not exit
					info('outline', 'error running fzf %s', msg)
				end

				vis:redraw()

				return true -- end here, skip remaining matchers
			end
		end
	else
		info('outline', 'no matchers registered for syntax "%s"', win.syntax)
	end

	return true
end)

return m
