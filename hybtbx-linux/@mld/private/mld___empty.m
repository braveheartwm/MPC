% HYSDEL 2.0.5 (Build: 20090715)
% Copyright (C) 1999-2002  Fabio D. Torrisi
% 
% HYSDEL comes with ABSOLUTELY NO WARRANTY;
% HYSDEL is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public
% License as published by the Free Software Foundation; either
% version 2 of the License, or (at your option) any later version.
S.name = 'empty';
S.MLDisvalid = 1;
S.MLDstructver = 2;
S.MLDsymtable = 1;
S.MLDrowinfo = 1;
S.Arr = [
1 ;
];
S.Arb = zeros(1, 0);
S.Abr = zeros(0, 1);
S.Abb = zeros(0, 0);

S.B1rr = [
1 ;
];
S.B1rb = zeros(1, 0);
S.B1br = zeros(0, 1);
S.B1bb = zeros(0, 0);

S.B2rb = zeros(1, 0);
S.B2bb = zeros(0, 0);

S.B3rr = zeros(1, 0);
S.B3br = zeros(0, 0);

S.Crr = zeros(0, 1);
S.Crb = zeros(0, 0);
S.Cbr = zeros(0, 1);
S.Cbb = zeros(0, 0);

S.D1rr = zeros(0, 1);
S.D1rb = zeros(0, 0);
S.D1br = zeros(0, 1);
S.D1bb = zeros(0, 0);

S.D2rb = zeros(0, 0);
S.D2bb = zeros(0, 0);

S.D3rr = zeros(0, 0);
S.D3br = zeros(0, 0);

S.E1 = zeros(0, 1);
S.E2 = zeros(0, 0);
S.E3 = zeros(0, 0);
S.E4 = zeros(0, 1);
S.E5 = zeros(0, 1);
S.A = [S.Arr, S.Arb; S.Abr, S.Abb];
S.B1 = [S.B1rr, S.B1rb; S.B1br, S.B1bb];
S.B2 = [S.B2rb; S.B2bb];
S.B3 = [S.B3rr; S.B3br];

S.C = [S.Crr, S.Crb; S.Cbr, S.Cbb];
S.D1 = [S.D1rr, S.D1rb; S.D1br, S.D1bb];
S.D2 = [S.D2rb; S.D2bb];
S.D3 = [S.D3rr; S.D3br];
S.rowinfo.state_upd{1}.section = 'Continuous';
S.rowinfo.state_upd{1}.item_type = 'Continuous';
S.rowinfo.state_upd{1}.defines = 'x';
S.rowinfo.state_upd{1}.depends = {'x', 'u'};
S.rowinfo.state_upd{1}.group = 1;
S.rowinfo.state_upd{1}.subgroup = 1;
S.rowinfo.state_upd{1}.subindex = 1;
S.rowinfo.state_upd{1}.source = 'x = x + u;';
S.rowinfo.state_upd{1}.sourceline = 17;
S.rowinfo.state_upd{1}.human = 'x = (1) * u + (1) * x';
S.ne = 0;

S.symtable{1}.name = 'MLD_epsilon';
S.symtable{1}.type = 'r';
S.symtable{1}.line_of_declaration = -1;
S.symtable{1}.line_of_first_use = -1;
S.symtable{1}.computable_order = -1;
S.symtable{1}.kind = 'p';
S.symtable{1}.value = 1e-006;
S.symtable{2}.name = 'pi';
S.symtable{2}.type = 'r';
S.symtable{2}.line_of_declaration = -1;
S.symtable{2}.line_of_first_use = -1;
S.symtable{2}.computable_order = -1;
S.symtable{2}.kind = 'p';
S.symtable{2}.value = 3.14159265358979;
S.symtable{3}.name = 'u';
S.symtable{3}.type = 'r';
S.symtable{3}.line_of_declaration = 12;
S.symtable{3}.line_of_first_use = 17;
S.symtable{3}.computable_order = 1;
S.symtable{3}.kind = 'u';
S.symtable{3}.index = 1;
S.symtable{3}.defined = NaN;
S.symtable{3}.min = -1;
S.symtable{3}.min_computed = 0;
S.symtable{3}.max = 1;
S.symtable{3}.max_computed = 0;
S.symtable{4}.name = 'x';
S.symtable{4}.type = 'r';
S.symtable{4}.line_of_declaration = 9;
S.symtable{4}.line_of_first_use = 17;
S.symtable{4}.computable_order = 1;
S.symtable{4}.kind = 'x';
S.symtable{4}.index = 1;
S.symtable{4}.defined = 1;
S.symtable{4}.min = -1;
S.symtable{4}.min_computed = 0;
S.symtable{4}.max = 1;
S.symtable{4}.max_computed = 0;
S.nxr = 1;
S.nxb = 0;
S.nx = 1;
S.nur = 1;
S.nub = 0;
S.nu = 1;
S.nyr = 0;
S.nyb = 0;
S.ny = 0;
S.nd = 0;
S.nz = 0;
S.ul = -inf * ones(S.nu, 1);
S.uu = +inf * ones(S.nu, 1);
S.xl = -inf * ones(S.nx, 1);
S.xu = +inf * ones(S.nx, 1);
S.yl = -inf * ones(S.ny, 1);
S.yu = +inf * ones(S.ny, 1);
S.dl = -inf * ones(S.nd, 1);
S.du = +inf * ones(S.nd, 1);
S.zl = -inf * ones(S.nz, 1);
S.zu = +inf * ones(S.nz, 1);
S.ul(1) = -1;
S.uu(1) = 1;
S.xl(1) = -1;
S.xu(1) = 1;
