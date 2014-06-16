function idx = find_column(header,label)

idx = -1;
for n = 1 : length(header)
    if strcmp(header{n},label), idx = n; break; end
end
