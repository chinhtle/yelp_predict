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
  MAX           = LIBERAL

  PERSONALITY_DESCRIPTION = {
    Personality::NONE          => '',
    Personality::PROSOCIAL     => 'Pro-social, agreeableness',
    Personality::RISK_TAKER    => 'Thrill takers, risk takers; more tolerant '\
                                  'of change, want new experiences.',
    Personality::ANXIOUS       => 'Immediate gratification and easily '\
                                  'frustrated by life\'s little '\
                                  'inconveniences; always in a rush.',
    Personality::PASSIVE       => 'Not risk takers and stay within the lines. '\
                                  'More passive versus aggressive, and do not '\
                                  'like change, mentality.',
    Personality::PERFECTIONIST => 'Perfectionist, focused, energetic, '\
                                  'sticklers for punctuality and excited by '\
                                  'challenges.',
    Personality::CRITICAL      => 'More judgmental and harsher on those '\
                                  'around them.',
    Personality::CONSCIENTIOUS => 'Eat to tame anxiety and stress, health '\
                                  'conscious (get vitamin C to be healthy), '\
                                  'and long-term mentality (plan for the '\
                                  'future).',
    Personality::OPEN_MINDED   => 'Open-minded, flexible.',
    Personality::INTUITIVE     => 'Sensing, rely on intuition rather than '\
                                  'logic.',
    Personality::LIBERAL       => 'More liberal than conservative.'
  }

  # Tightly coupled with personality map defined in
  # yelp_user_csv_personality_update.py
  PERSONALITY_KEYS = {Personality::PROSOCIAL     => 'Prosocial',
                      Personality::RISK_TAKER    => 'Risk Taker',
                      Personality::ANXIOUS       => 'Anxious',
                      Personality::PASSIVE       => 'Passive',
                      Personality::PERFECTIONIST => 'Perfectionist',
                      Personality::CRITICAL      => 'Critical',
                      Personality::CONSCIENTIOUS => 'Conscientious',
                      Personality::OPEN_MINDED   => 'Open minded',
                      Personality::INTUITIVE     => 'Intuitive',
                      Personality::LIBERAL       => 'Liberal'}

  PERSONALITY_NUM_KEYS = {Personality::PROSOCIAL     => 'num_prosocial',
                          Personality::RISK_TAKER    => 'num_risktaker',
                          Personality::ANXIOUS       => 'num_anxious',
                          Personality::PASSIVE       => 'num_passive',
                          Personality::PERFECTIONIST => 'num_perfectionist',
                          Personality::CRITICAL      => 'num_critical',
                          Personality::CONSCIENTIOUS => 'num_conscientious',
                          Personality::OPEN_MINDED   => 'num_openminded',
                          Personality::INTUITIVE     => 'num_intuitive',
                          Personality::LIBERAL       => 'num_liberal'}
end
