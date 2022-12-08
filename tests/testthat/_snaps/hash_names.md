# Hashing outputs as expected

    Code
      hash_names(c("sweet", "baby", "jesus"))
    Output
        label hash_short
      1 sweet     fcd77f
      2  baby     c7d8fe
      3 jesus     8879cc
                                                                    hash
      1 fcd77f26238788f3e0910b6bd30a704b211bd7a6445f7e72a61845b962e36781
      2 c7d8fe7679403e99cf48afd82b7dee6639a8d517a7a026167987ced03a98ffec
      3 8879ccbd8f26bbf75882f78370c7a5e70615202411212af6bdf383586e29b069

---

    Code
      hash_names(NA)
    Output
        label hash_short
      1    na     899a65
                                                                    hash
      1 899a65bcb1ff0a32ae7d70c7c7566ce695855a48489008037ef07aa9176adfa8

# Hashing with salting

    Code
      hash_names("toto", salt = 123456)
    Output
        label hash_short
      1  toto     8d42a7
                                                                    hash
      1 8d42a7e6cd156701b2fb2bee1095367cf7a0e9477783574c540a97e01715b15c

