--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

return {
    names = {
        'Amaryll',
        'Ciyradyl',
        'Glorfindel',
        'Galadriel',
        'Kaylessa',
        'Llamriel',
        'Lorelei',
        'Morwen',
        'Renestrae',
        'Shandalar',
        'Sinnafain',
        'Talaedra',
        'Valindra',
        'Teharissa',
    },
    filters = {
        '-',
        '^.{1,5}$',
        'rnd',
        '[bcdfghjklmnpqrstvwxz]$',
        'drn',
        'dr$',
        '$thr',
        'lr$',
        '(.)\\1\\1',
        '(?i)\b[b-df-hj-np-tv-z]+\\b',
    },
}
