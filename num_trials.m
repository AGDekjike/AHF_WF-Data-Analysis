N = zeros(5,6,6);

for animal = 1:6
    for stage = 1:5
        for day = (stage-1)*5+1:stage*5
            for cls = 1:6
                num = size(A{1,animal}{1,day}{1,cls},4);
                N(stage,cls,animal) = N(stage,cls,animal) + num;
            end
        end
    end
end