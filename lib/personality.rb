# encoding: utf-8

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

  INTROVERTED = 0
  EXTROVERTED = 1

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

  INTRO_EXTRO_KEYS = {
    INTROVERTED => 'Introverted',
    EXTROVERTED => 'Extroverted'
  }

  INTRO_EXTRO_NUM_KEYS = {INTROVERTED   => 'num_introverted',
                          EXTROVERTED   => 'num_extroverted'}

  PERSONALITY_INTRO_EXTRA_MAP = {
    PERSONALITY_KEYS[PROSOCIAL]     => INTRO_EXTRO_KEYS[EXTROVERTED],
    PERSONALITY_KEYS[RISK_TAKER]    => INTRO_EXTRO_KEYS[EXTROVERTED],
    PERSONALITY_KEYS[ANXIOUS]       => INTRO_EXTRO_KEYS[EXTROVERTED],
    PERSONALITY_KEYS[PASSIVE]       => INTRO_EXTRO_KEYS[INTROVERTED],
    PERSONALITY_KEYS[PERFECTIONIST] => INTRO_EXTRO_KEYS[INTROVERTED],
    PERSONALITY_KEYS[CRITICAL]      => INTRO_EXTRO_KEYS[INTROVERTED],
    PERSONALITY_KEYS[CONSCIENTIOUS] => INTRO_EXTRO_KEYS[INTROVERTED],
    PERSONALITY_KEYS[OPEN_MINDED]   => INTRO_EXTRO_KEYS[EXTROVERTED],
    PERSONALITY_KEYS[INTUITIVE]     => INTRO_EXTRO_KEYS[EXTROVERTED],
    PERSONALITY_KEYS[LIBERAL]       => INTRO_EXTRO_KEYS[EXTROVERTED]
  }

  INTRO_EXTRO_PRONOUNCE = {
    INTRO_EXTRO_KEYS[INTROVERTED]   => '\\ˌin-trə-ˈvər-zhən, -shən\\',
    INTRO_EXTRO_KEYS[EXTROVERTED]   => '\\ˌek-strə-ˈvər-zhən, -shən\\'
  }

  INTRO_EXTRO_DESCRIPTION = {
    INTRO_EXTRO_KEYS[INTROVERTED]   => 'Individuals who are quiet, reserved, '\
                                       'thoughtful, and self-reliant. Likely '\
                                       'to prefer solitary work and leisure '\
                                       'activities.  Tend to mull things over '\
                                       'before formulating a reaction, and '\
                                       'their energy is regenerated by time '\
                                       'spent alone.',
    INTRO_EXTRO_KEYS[EXTROVERTED]   => 'Often leaders.  Work well in groups '\
                                       'and prefer being with others.  '\
                                       'Other personality traits include '\
                                       'optimism, risk taking, and love of '\
                                       'excitement and change.  Prefer having '\
                                       'company and tend to have many friends.'
  }

  INTRO_EXTRO_TO_BUSINESS_TERM = {
    INTRO_EXTRO_KEYS[INTROVERTED]   => 'Introversion',
    INTRO_EXTRO_KEYS[EXTROVERTED]   => 'Extroversion'
  }

  INTRO_EXTRO_BAR_TYPE = {
    INTROVERTED => 'progress-bar-info',
    EXTROVERTED => 'progress-bar-danger'
  }

  INTRO_EXTRO_GLYPH_TYPE = {
    INTROVERTED => 'glyphicon-cloud',
    EXTROVERTED => 'glyphicon-fire'
  }

end
