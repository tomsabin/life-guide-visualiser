require 'test/unit'
require './methods.rb'

class RegexTest < Test::Unit::TestCase
  def test_show_regex
    pass = [
      'show welcome',
      'show login',
      'show data1',
      'show Doctors_Qs',
      'show men_other_symptoms if (Doctors_Qs.men_headache = "men_yes")',
      'show s1pg09afyc if (warning)',
    ]
    fail = [
      'show st_pA1b.selected1 if (st_condition1)',
      'show st_pA1c.advice1',
      'show FAQpain.female if (gender = "female")',
      'show',
      'set default s2reasons.reason1 to load reasonstoloseweight.reason1 for username',
      'begin faqsmenusection'
    ]
    pass.each { |input| assert_equal true, show_token?(input) }
    fail.each { |input| assert_equal nil, show_token?(input) }
  end
  
  def test_after_regex
    pass = [
      'after register if (makenewuser(register.username, register.password)) goto login',
      'after Safety_Qs_fine if (Safety_Qs_fine.d_q_symptom = "cough") goto cough',
      'after signupconfirm if (loadvalue(username, "group") = "intervention") goto baseline1a',
      'after s6increase if (paplan = "walk") goto s6benefitswalking',
    ]
    fail = [
      'after foo',
      'after foo ',
      'after page if page goto page',
      'after page goto anotherpage',
      'show',
      'set default s2reasons.reason1 to load reasonstoloseweight.reason1 for username',
      'begin faqsmenusection'
    ]
    pass.each { |input| assert_equal true, after_token?(input) }
    fail.each { |input| assert_equal nil, after_token?(input) }
  end
  
  def test_section_begin_regex
    pass = [
      'begin session2optionalsection2',
      'begin section session2optionalsection2',
      'begin introduction',
      'begin section introduction',
      'begin',
      'begin section'
    ]
    fail = [
      '#begin section',
      'end'
    ]
    pass.each { |input| assert_equal true, begin_token?(input) }
    fail.each { |input| assert_equal nil, begin_token?(input) }
  end
  
  def test_section_end_regex
    pass = [
      'end',
      'end section',
      'end section foo'
    ]
    fail = [
      '#end',
      '#end section',
      'begin'
    ]
    pass.each { |input| assert_equal true, end_token?(input) }
    fail.each { |input| assert_equal nil, end_token?(input) }
  end
  
  def test_jumpto_link_regex
    pass = [
      '<a href="?jumpto=pW1">',
      '<a href="?jumpto=Doctors_Qs">',
      '<a class="popup" href="?jumpto=pT1advice3FightInfection">',
      '<a id="foo" class="popup" href="?jumpto=pT1advice3FightInfection">'
    ]
    fail = [
      '<a href="somewhereelse.co.uk">',
      '<a href="jumpto.co.uk">',
      '<a class="?jumpto=foo">'
    ]
    pass.each { |input| assert_equal true, jumpto_link_token?(input) }
    fail.each { |input| assert_equal nil, jumpto_link_token?(input) }
  end
  
  def test_div_link_regex
    pass = [
      '<div id="button-1" class="submit-jumpto-button" label="welcome">',
      '<div id="button-2" class="submit-jumpto-button" label="login">'
    ]
    fail = [
      '<div id="foo" class="submit-jumpto-button">',
      '<div id="foo" label="foo">',
      '<div id="button-3" class="jumpto-button">'
    ]
    pass.each { |input| assert_equal true, div_link_token?(input) }
    fail.each { |input| assert_equal nil, div_link_token?(input) }
  end
end

class LgilParserTest < Test::Unit::TestCase
  @raw
  @links
  @nodes
  
  def test_clean_lgil
  end
  
  def test_parse_lgil
  end
end