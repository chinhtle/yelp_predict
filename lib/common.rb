class Common
  CRAWL_USER_AGENT = {
    "User-Agent" => "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)"
  }

  # Time to wait between each request to avoid being identified as crawler
  GET_REQ_TIME = 0.5 # seconds

  def self.draw_stars rating, size
    res = ''
    total_stars = 5
    full_stars = (rating / 1).to_i
    enable_half_star = false

    # Sizes are as follows: fa-lg, fa-2x, fa-3x, fa-4x, fa-5x
    star_size = "fa-#{size}x"

    if (rating - full_stars) >= 0.5
      enable_half_star = true
    end

    # Draw the full stars
    for i in 0..full_stars-1
      res << "<i class=\"fa fa-star #{star_size}\"></i>"
    end

    if enable_half_star
      res << "<i class=\"fa fa-star-half-o #{star_size}\"></i>"
    end

    # Calculate any empty stars we need to draw.
    remaining_stars = total_stars - full_stars

    # And if half star was enabled, subtract that as well as 1 full star.
    if enable_half_star
      remaining_stars = remaining_stars - 1
    end

    for i in 0..remaining_stars-1
      res << "<i class=\"fa fa-star-o #{star_size}\"></i>"
    end

    return res
  end
end
