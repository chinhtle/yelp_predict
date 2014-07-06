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

end
