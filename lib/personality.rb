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
    NONE:           '',
    PROSOCIAL:      'Pro-social, agreeableness',
    RISK_TAKER:     'Thrill takers, risk takers; more tolerant of change, want
                     new experiences.',
    ANXIOUS:        'Immediate gratification and easily frustrated by lifes
                     little inconveniences; always in a rush.',
    PASSIVE:        'Not risk takers and stay within the lines. More passive
                     versus aggressive, and do not like change, mentality.',
    PERFECTIONIST:  'Perfectionist, focused, energetic, sticklers for
                     punctuality and excited by challenges.',
    CRITICAL:       'More judgmental and harsher on those around them.',
    CONSCIENTIOUS:  'Eat to tame anxiety and stress, health conscious
                     (get vitamin C to be healthy), and long-term mentality
                     (plan for the future).',
    OPEN_MINDED:    'Open-minded, flexible.',
    INTUITIVE:      'Sensing, rely on intuition rather than logic.',
    LIBERAL:        'More liberal than conservative.'
  }

  # Class method for converting personality enum to string equivalent
  def self.personality_to_str(type)
    case type
      when NONE
        str = 'None'
      when PROSOCIAL
        str = 'Prosocial'
      when RISK_TAKER
        str = 'Risk-taker'
      when ANXIOUS
        str = 'Anxious'
      when PASSIVE
        str = 'Passive'
      when PERFECTIONIST
        str = 'Perfectionist'
      when CRITICAL
        str = 'Critical'
      when CONSCIENTIOUS
        str = 'Conscientious'
      when OPEN_MINDED
        str = 'Open-minded'
      when INTUITIVE
        str = 'Intuitive'
      when LIBERAL
        str = 'Liberal'
      else
        str = 'Unknown'
    end
  end
end
