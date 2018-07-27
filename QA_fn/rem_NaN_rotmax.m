function new_rotmax = rem_NaN_rotmax(rotmax)
%REM_NAN_ROTMAX removes NaN from the last row of a rotation matrix
%   new_rotmax = REM_NAN_ROTMAX(rotmax) takes a rotation matrix that has
%   had the zeros in the matrix replaced by NaN and replaces the NaN in the
%   final row and replaces it with 0
%
%   Authors: John A. Walker
%   Version: 1.0.1, 05.22.2018

new_rotmax = reshape(rotmax, size(rotmax, 1), 16);

for i = 1:size(new_rotmax, 1)
    for j = 13:15
        if isnan(new_rotmax(i, j))
            new_rotmax(i, j) = 0.0;
        end
    end
end