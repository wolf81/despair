--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

return {
    names = {
        'Aerendyl',
        'Curunir',
        'Edrahil',
        'Earendil',
        'Eladithas',
        'Elrond',
        'Mithrandir',
        'Ornthalas',
        'Othorion',
        'Thranduil',
        'Uthorim',
    },
    filters = {
        '-',
        '^.{1,5}$',
        'rnd',
        'drn',
        'dr$',
        '$thr',
        'lr$',
        '(.)\\1\\1',
        '(?i)\b[b-df-hj-np-tv-z]+\\b',
    },
}
