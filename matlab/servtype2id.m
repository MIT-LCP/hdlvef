function id = servtype2id(data)

switch data
    case 'MICU'
        id = [1 0 0 0];
        
    case 'FICU'
        id = [1 0 0 0];
        
    case 'CCU'
        id = [0 1 0 0];
        
    case 'SICU'
        id = [0 0 1 0];
        
    case 'CSRU'
        id = [0 0 0 1];
        
    otherwise
        id = [-1 -1 -1 -1];
end
