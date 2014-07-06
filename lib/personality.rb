class Personality
  NONE          = -1
  PROSOCIAL     = 0   # Sweet
  RISK_TAKER    = 1   # Spicy
  ANXIOUS       = 2   # Salty
  PASSIVE       = 3   # Comfort Foods
  PERFECTIONIST = 4   # Crunchy
  CRITICAL      = 5   # Tart/Sour
  CONSCIENTIOUS = 6   # Citrus
  OPEN_MINDED   = 7   # Exotic Foods
  INTUITIVE     = 8   # Chocolate
  LIBERAL       = 9   # Alcohol

  # Add new personality types above and assign last as max.
  MAX_PERSONALITIES = LIBERAL

  PERSONALITY_DESCRIPTION = {
    NONE          => '',
    PROSOCIAL     => 'Pro-social, agreeableness',
    RISK_TAKER    => 'Thrill takers, risk takers; more tolerant '\
                     'of change, want new experiences.',
    ANXIOUS       => 'Immediate gratification and easily '\
                     'frustrated by life\'s little '\
                     'inconveniences; always in a rush.',
    PASSIVE       => 'Not risk takers and stay within the lines. '\
                     'More passive versus aggressive, and do not '\
                     'like change, mentality.',
    PERFECTIONIST => 'Perfectionist, focused, energetic, '\
                     'sticklers for punctuality and excited by '\
                     'challenges.',
    CRITICAL      => 'More judgmental and harsher on those '\
                     'around them.',
    CONSCIENTIOUS => 'Eat to tame anxiety and stress, health '\
                     'conscious (get vitamin C to be healthy), '\
                     'and long-term mentality (plan for the '\
                     'future).',
    OPEN_MINDED   => 'Open-minded, flexible.',
    INTUITIVE     => 'Sensing, rely on intuition rather than '\
                     'logic.',
    LIBERAL       => 'More liberal than conservative.'
  }

  # Tightly coupled with personality map defined in
  # yelp_user_csv_personality_update.py
  PERSONALITY_KEYS = {PROSOCIAL     => 'Prosocial',
                      RISK_TAKER    => 'Risk Taker',
                      ANXIOUS       => 'Anxious',
                      PASSIVE       => 'Passive',
                      PERFECTIONIST => 'Perfectionist',
                      CRITICAL      => 'Critical',
                      CONSCIENTIOUS => 'Conscientious',
                      OPEN_MINDED   => 'Open minded',
                      INTUITIVE     => 'Intuitive',
                      LIBERAL       => 'Liberal'}

  PERSONALITY_NUM_KEYS = {PROSOCIAL     => 'num_prosocial',
                          RISK_TAKER    => 'num_risktaker',
                          ANXIOUS       => 'num_anxious',
                          PASSIVE       => 'num_passive',
                          PERFECTIONIST => 'num_perfectionist',
                          CRITICAL      => 'num_critical',
                          CONSCIENTIOUS => 'num_conscientious',
                          OPEN_MINDED   => 'num_openminded',
                          INTUITIVE     => 'num_intuitive',
                          LIBERAL       => 'num_liberal'}

  PERSONALITY_INTRO_EXTRA_MAP = {
    PERSONALITY_KEYS[PROSOCIAL]     => 'Extraverted', #Introverted
    PERSONALITY_KEYS[RISK_TAKER]    => 'Extraverted', #Introverted
    PERSONALITY_KEYS[ANXIOUS]       => 'Extraverted',
    PERSONALITY_KEYS[PASSIVE]       => 'Introverted',
    PERSONALITY_KEYS[PERFECTIONIST] => 'Introverted',
    PERSONALITY_KEYS[CRITICAL]      => 'Introverted',
    PERSONALITY_KEYS[CONSCIENTIOUS] => 'Introverted',
    PERSONALITY_KEYS[OPEN_MINDED]   => 'Extraverted',
    PERSONALITY_KEYS[INTUITIVE]     => 'Extraverted',
    PERSONALITY_KEYS[LIBERAL]       => 'Extraverted'
  }

  VOTES_FUNNY   = 10
  VOTES_USEFUL  = 11
  VOTES_COOL    = 12
  REVIEW_CNT    = 13
  NUM_FRIENDS   = 14
  NUM_FANS      = 15
  AVG_STAR      = 16
  NUM_COMPS     = 17

  MAX_FEATURES = NUM_COMPS

  FEATURES_KEYS = {
    VOTES_FUNNY   => 'votes_funny',
    VOTES_USEFUL  => 'votes_useful',
    VOTES_COOL    => 'votes_cool',
    REVIEW_CNT    => 'review_count',
    NUM_FRIENDS   => 'friends',
    NUM_FANS      => 'fans',
    AVG_STAR      => 'average_stars',
    NUM_COMPS     => 'compliments'
  }

  FEATURES_TO_NOM_MAP = {
    # FEATURES_KEYS[VOTES_FUNNY] => {thresh: '50',
    #                                nom_low: 'low',
    #                                nom_high: 'high'},
    # FEATURES_KEYS[VOTES_USEFUL] => {thresh: '100',
    #                                nom_low: 'low',
    #                                nom_high: 'high'},
    # FEATURES_KEYS[VOTES_COOL] => {thresh: '60',
    #                                nom_low: 'low',
    #                                nom_high: 'high'},
    FEATURES_KEYS[REVIEW_CNT] => {thresh: '40',
                                   nom_low: 'low',
                                   nom_high: 'high'},
    # FEATURES_KEYS[NUM_FRIENDS] => {thresh: '50',
    #                                nom_low: 'low',
    #                                nom_high: 'high'},
    # FEATURES_KEYS[NUM_FANS] => {thresh: '50',
    #                                nom_low: 'low',
    #                                nom_high: 'high'},
    # FEATURES_KEYS[AVG_STAR] => {thresh: '2.5',
    #                                nom_low: 'low',
    #                                nom_high: 'high'},
    # FEATURES_KEYS[NUM_COMPS] => {thresh: '50',
    #                             nom_low: 'low',
    #                             nom_high: 'high'}
  }

end
