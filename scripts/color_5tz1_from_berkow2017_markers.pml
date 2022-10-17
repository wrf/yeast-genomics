hide everything
show cartoon
set_color colordefault, [0.75,0.75,0.58]
color colordefault, all

set_color red60, [0.75,0.47,0.47]
set_color red70, [0.77,0.38,0.38]
set_color red80, [0.79,0.29,0.29]
set_color red90, [0.82,0.21,0.21]
set_color red95, [0.84,0.13,0.13]

select 1sub_A, (chain A & resi 61,114,126,145,257,405,435,446,448,450,464,467,471,502)
color red60, 1sub_A
select 2sub_A, (chain A & resi 132,449)
color red80, 2sub_A
select 3sub_A, (chain A & resi 143)
color red95, 3sub_A

