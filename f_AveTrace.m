function new_trace = f_AveTrace(trace,aveLength)

if aveLength > 1
    dim1 = aveLength;
    dim2 = ceil(size(trace,1)/dim1);
    t_trace = nan(dim2*dim1,size(trace,2));
    t_trace(1:size(trace,1),:) = trace;
    
    new_trace = nan(dim2,size(trace,2));
    for n = 1 : size(trace,2)
        working = t_trace(:,n);
        working = reshape(working,dim1,dim2);
        new_trace(:,n) = nanmean(working);
    end
else
    new_trace = trace;
end


end