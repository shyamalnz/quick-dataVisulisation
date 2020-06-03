function [ num ] = str2numEng( str )
%[ time ] = f_TimeSI( time )
%   Converts value in str to into num respecting SI prefixes
%   prefixes: Y,Z,E,P,T,G,M,k,m,\mu OR u,n,p,f,a,z,y
%
%   %%Returned Values
%   num                as a double
%
%   inital updated 19-06-15 - Shyamal

prefices={'Y','Z','E','P','T','G','M','k','','m','\mu','n','p','f','a','z','y'};
prefices = fliplr(prefices);

if ~isempty(str) && ischar(str) % checks if TIME contains a string
    str = char(str);
    num = regexp(str,'[-0-9\.]+','match');
    num = num{1};
    len = length(num);
    num = str2num(num);
    if length(str) > len
    unit = strtrim(str(len+1:end));
        while ~isempty(unit)
            prefix = find(strcmp(unit,prefices));
            if isempty(prefix)
                if strcmp(unit,'u')
                    prefix = find(strcmp('\mu',prefices));
                end
            end
            
            if ~isempty(prefix)
                num = num*10^(3*(prefix-9));
                unit = '';
            else
                unit = unit(1:end-1);
            end
        end
    end
elseif isempty(str)
    num = [];
else
    num = str;
end

end

