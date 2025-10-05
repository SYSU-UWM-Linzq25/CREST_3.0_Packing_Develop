function slope=CalSlopeNoData(obj,indexNodata)
% calculates the edge cell whose next cell falls outside of the
% basin
% a b c
% d e f
% g h i
[rows,columns]=size(obj.DEM);
[C,R]=meshgrid(1:columns,1:rows);
R=R(indexNodata);
C=C(indexNodata);
r_a=R-1;c_a=C-1;r_b=R-1;c_b=C;r_c=R-1;c_c=C+1;
r_d=R;  c_d=C-1;              r_f=R;  c_f=C+1;
r_g=R+1;c_g=C-1;r_h=R+1;c_h=C;r_i=R+1;c_i=C+1;
%             dem=obj.DEM(indexNodata);
z_a=obj.FillAdjDEM(r_a,c_a,R,C);
z_b=obj.FillAdjDEM(r_b,c_b,R,C);
z_c=obj.FillAdjDEM(r_c,c_c,R,C);
z_d=obj.FillAdjDEM(r_d,c_d,R,C);
z_f=obj.FillAdjDEM(r_f,c_f,R,C);
z_g=obj.FillAdjDEM(r_g,c_g,R,C);
z_h=obj.FillAdjDEM(r_h,c_h,R,C);
z_i=obj.FillAdjDEM(r_i,c_i,R,C);


dzdx=(z_c+2.0*z_f+z_i)-(z_a+2.0*z_d+z_g);
dzdx=dzdx./(8.0*obj.LenEW(indexNodata));

dzdy=(z_g+2.0*z_h+z_i)-(z_a+2.0*z_b+z_c);
dzdy=dzdy/(8.0*obj.LenSN);

slope=sqrt(dzdx.^2+dzdy.^2);
end