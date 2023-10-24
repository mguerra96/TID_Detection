function s_ext_o = My_Sig_Extension(s,ext_type,L)


if size(s,1)>size(s,2)
    s=s';
end
if size(s,1)>1
    size_s=2;
else
    size_s=1;
end

L=round(L); % we want to have natural numbers
Ls=size(s,2);

if size_s>1
    disp('Code missing')
    s_ext_o=[];
    return
end
if size(ext_type,2)==1
    s_ext_o = wextend(size_s,ext_type{1},s,L);
else
    
    N_ext=floor(L/Ls);
    temp_s=s;
    for ii=1:N_ext
        if rem(ii,2)==1
            s_ext_o_1 = wextend(size_s,ext_type{1},temp_s,Ls);
            s_ext_o_2 = wextend(size_s,ext_type{2},temp_s,Ls);
        else
            s_ext_o_1 = wextend(size_s,ext_type{2},temp_s,Ls);
            s_ext_o_2 = wextend(size_s,ext_type{1},temp_s,Ls);
        end
        temp_s = [s_ext_o_1(1:end-Ls) s_ext_o_2(end-Ls+1:end)];
    end
    if rem(L,Ls)>0
        if rem(N_ext,2)==0
            s_ext_o_1 = wextend(size_s,ext_type{1},temp_s,rem(L,Ls));
            s_ext_o_2 = wextend(size_s,ext_type{2},temp_s,rem(L,Ls));
        else
            s_ext_o_1 = wextend(size_s,ext_type{2},temp_s,rem(L,Ls));
            s_ext_o_2 = wextend(size_s,ext_type{1},temp_s,rem(L,Ls));
        end
        temp_s = [s_ext_o_1(1:end-rem(L,Ls)) s_ext_o_2(end-rem(L,Ls)+1:end)];
    end
    s_ext_o = temp_s;
end
    
end