            elsif ($arg[3] eq "addplayer") {
                if (!ha($username)) {
                    privmsg("You don't have access to addplayer.", $usernick);
                }
                else {
                    if ($#arg < 8 || $arg[8] eq "") {
                        privmsg("Try: ADDPLAYER <ircnick> <hostname> <char name> <password> <class>",
                                $usernick);
                        privmsg("IE : ADDPLAYER Poseidon God\@of.the.Sea Poseidon MyPassword God of the Sea",$usernick);
                    }
                    elsif ($pausemode) {
                        privmsg("Sorry, new accounts may not be registered ".
                                "while the bot is in pause mode; please wait ".
                                "a few minutes and try again.",$usernick);
                    }
                    elsif (exists $rps{$arg[6]} || ($opts{casematters} &&
                           scalar(grep { lc($arg[6]) eq lc($_) } keys(%rps)))) {
                        privmsg("Sorry, that character name is already in use.",
                                $usernick);
                    }
                    elsif (lc($arg[6]) eq lc($opts{botnick}) ||
                           lc($arg[6]) eq lc($primnick)) {
                        privmsg("Sorry, that character name cannot be ".
                                "registered.",$usernick);
                    }
                    elsif (!exists($onchan{$arg[4]})) {
                        privmsg("Sorry, $arg[4] is not on the channel $opts{botchan}.",
                                $usernick);
                    }
                    elsif (length($arg[6]) > 16 || length($arg[6]) < 1) {
                        privmsg("Sorry, character names must be < 17 and > 0 ".
                                "chars long.", $usernick);
                    }
                    elsif ($arg[6] =~ /^#/) {
                        privmsg("Sorry, character names may not begin with #.",
                                $usernick);
                    }
                    elsif ($arg[6] =~ /\001/) {
                        privmsg("Sorry, character names may not include ".
                                "character \\001.",$usernick);
                    }
                    elsif ($opts{noccodes} && ($arg[6] =~ /[[:cntrl:]]/ ||
                           "@arg[8..$#arg]" =~ /[[:cntrl:]]/)) {
                        privmsg("Sorry, neither character names nor classes ".
                                "may include control codes.",$usernick);
                    }
                    elsif ($opts{nononp} && ($arg[6] =~ /[[:^print:]]/ ||
                           "@arg[8..$#arg]" =~ /[[:^print:]]/)) {
                        privmsg("Sorry, neither character names nor classes ".
                                "may include non-printable chars.",$usernick);
                    }
                    elsif (length("@arg[8..$#arg]") > 30) {
                        privmsg("Sorry, character classes must be < 31 chars ".
                                "long.",$usernick);
                    }
                    elsif (time() == $lastreg) {
                        privmsg("Wait 1 second and try again.",$usernick);                
                    }
                    else {
                        if ($opts{voiceonlogin}) {
                            sts("MODE $opts{botchan} +v :$arg[4]");
                        }
                        ++$registrations;
                        $lastreg = time();
                        $rps{$arg[6]}{next} = $opts{rpbase};
                        $rps{$arg[6]}{class} = "@arg[8..$#arg]";
                        $rps{$arg[6]}{level} = 0;
                        $rps{$arg[6]}{online} = 1;
                        $rps{$arg[6]}{nick} = $arg[4];
                        $rps{$arg[6]}{userhost} = $arg[4]."!".$arg[5];
                        $rps{$arg[6]}{created} = time();
                        $rps{$arg[6]}{lastlogin} = time();
                        $rps{$arg[6]}{pass} = crypt($arg[7],mksalt());
                        $rps{$arg[6]}{x} = int(rand($opts{mapx}));
                        $rps{$arg[6]}{y} = int(rand($opts{mapy}));
                        $rps{$arg[6]}{alignment}="n";
                        $rps{$arg[6]}{isadmin} = 0;
                        for my $item ("ring","amulet","charm","weapon","helm",
                                      "tunic","pair of gloves","shield",
                                      "set of leggings","pair of boots") {
                            $rps{$arg[6]}{item}{$item} = 0;
                        }
                        for my $pen ("pen_mesg","pen_nick","pen_part",
                                     "pen_kick","pen_quit","pen_quest",
                                     "pen_logout","pen_logout") {
                            $rps{$arg[6]}{$pen} = 0;
                        }
                        chanmsg("Welcome $arg[6]\'s new player $arg[4], the ".
                                "@arg[8..$#arg]! Next level in ".
                                duration($opts{rpbase}).".");
                        privmsg("Success! Account $arg[6] created.", $usernick);
                        notice("Logon successful. Next level in ".
                               duration($rps{$arg[6]}{next}).".", $arg[4]);

                    }
                }
            }
