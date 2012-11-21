#===============================================================================
#
#   Proc's
#
#===============================================================================

#Returns the distance between two blocks, or any other 3d points, for that matter
proc(_3d_distance, @arr1, @arr2,
    return(
        floor(
            sqrt(
                add(
                    pow(subtract(@arr2[0], @arr1[0]), 2),
                    pow(subtract(@arr2[1], @arr1[1]), 2),
                    pow(subtract(@arr2[2], @arr1[2]), 2)
                )
            )
        )
    )
)

#Given two blocks, iterates through all the blocks inside the cuboid, and calls the 
#user defined function on them. The used defined procedure should accept 3 parameters,
#the x, y, and z coordinates of the block.
proc(_iterate_cuboid, @b1, @b2, @proc_name,
    for(assign(@x, min(@b1[0], @b2[0])), lte(@x, max(@b1[0], @b2[0])), inc(@x),
        for(assign(@y, min(@b1[1], @b2[1])), lte(@y, max(@b1[1], @b2[1])), inc(@y),
            for(assign(@z, min(@b1[2], @b2[2])), lte(@z, max(@b1[2], @b2[2])), inc(@z),
                call_proc(@proc_name, @x, @y, @z)
            )
        )
    )
)
proc(_bc, @label, @str,
broadcast(concat(color(yellow), '[', color(green), @label, color(yellow), '] ', color(white), @str))
)

# The Proc's userhist, kick, ban, jail, banq and jailq are originally from MCAU's github (https://github.com/mcau). Slightly modified to use on OresomeCraft!

proc(_userhist, @player,
    assign(@player,to_lower(@player))
    assign(@kickcount, get_value(concat('bandb.',@player,'.kick.count')))
    assign(@bancount, get_value(concat('bandb.',@player,'.ban.count')))
    assign(@banrcount, get_value(concat('bandb.',@player,'.ban.rcount')))
    assign(@jailcount, get_value(concat('bandb.',@player,'.jail.count')))
    assign(@jailrcount, get_value(concat('bandb.',@player,'.jail.rcount')))
    msg(concat(color(green),'RAP sheet for ',@player))
    msg(concat(color(red),'=======================Jails======================='))
    if(is_null(@jailrcount),msg('no records availble to /rap yet for this player'),
        for(assign(@i,0),lte(@i,@jailrcount),inc(@i),
            assign(@record,get_values(concat('bandb.',@player,'.jail.',@i)))
            #msg(concat('bandb.',@player,'.jail.',@i))
            if(equals(array_size(@record),0),
                msg(@i,' missing'),
                msg(@i,' ',array_implode(@record,','))
            )
        )
    )
    msg(concat(color(red),'=======================Bans======================='))
    if(is_null(@banrcount),msg('no records availble to /rap yet for this player'),
        for(assign(@i,0),lte(@i,@banrcount),inc(@i),
            assign(@record,get_values(concat('bandb.',@player,'.ban.',@i)))
            #msg(concat('bandb.',@player,'.jail.',@i))
            if(equals(array_size(@record),0),
                msg(@i,' missing'),
                msg(@i,' ',array_implode(@record,','))
            )
        )
    )
    msg(concat(color(green),@player,' has been kicked ',@kickcount,' time(s), jailed ',@jailcount,' times(s) and banned ',@bancount,' time(s) since bandb started recording.'))
)

proc(_kick, @player, @reason,
    if(equals(length(@player),0),
        msg('Kick a user.')
        msg('/kick <playername> <reason>')
    ,#else
        try(
            assign(@player,player(@player)),
            @var,
            assign(@player,@player)
            die(concat(color(red),'Can\'t kick an offline user.'))
        )
    )
    run(/kick @player @reason)
    assign(@lcpl,to_lower(@player))
    assign(@count, get_value(concat('bandb.',@lcpl,'.kick.count')))
    if(equals(@count,''),assign(@count,1))
    if(is_null(@count),assign(@count,1),assign(@count,inc(@count)))
    store_value(concat('bandb.',@lcpl,'.kick.count'),@count)
)

proc(_jail, @cmnd, @player, @jail, @datediff, @reason,
    assign(@jailmod,player())
    if(equals(length(@reason),0),
        msg('Jail a user.')
        msg(concat(@cmnd,' <playername> <jail> <datediff> <reason>'))
    ,#else
        try(
            assign(@player,player(@player)),
            @var,
            assign(@player,@player)
            msg(color(red),'User offline. I hope you got their name right.')
        )
        run(@cmnd @player @jail @datediff)
        assign(@lcpl,to_lower(@player))
        assign(@rcount, get_value(concat('bandb.',@lcpl,'.jail.rcount')))
        if(is_null(@rcount),assign(@rcount,1),assign(@rcount,inc(@rcount)))
        store_value(concat('bandb.',@lcpl,'.jail.rcount'),@rcount)
        store_value(concat('bandb.',@lcpl,'.jail.',@rcount,'.reason'), @reason)
        store_value(concat('bandb.',@lcpl,'.jail.',@rcount,'.length'), @datediff)
        store_value(concat('bandb.',@lcpl,'.jail.',@rcount,'.mod'), @jailmod)
        store_value(concat('bandb.',@lcpl,'.jail.',@rcount,'.time'), time())

        assign(@jailcount, get_value(concat('bandb.',@lcpl,'.jail.count')))
        if(is_null(@jailcount),assign(@jailcount,0))
        store_value(concat('bandb.',@lcpl,'.jail.count'),inc(@jailcount))
    )
)

proc(_jailq,@player,
    assign(@lcplayer,to_lower(@player))
    assign(@rcount, get_value(concat('bandb.',@lcplayer,'.jail.rcount')))
    if(is_null(@rcount),assign(@rcount,0))
    assign(@jailreason,get_value(concat('bandb.',@lcplayer,'.jail.',@rcount,'.reason')))
    assign(@jaillength,get_value(concat('bandb.',@lcplayer,'.jail.',@rcount,'.length')))
    assign(@jailcount,get_value(concat('bandb.',@lcplayer,'.jail.count')))
    assign(@jailmod,get_value(concat('bandb.',@lcplayer,'.jail.',@rcount,'.mod')))
    assign(@time,get_value(concat('bandb.',@lcplayer,'.jail.',@rcount,'.time')))
    if(is_null(@time),assign(@time,0))
    assign(@diff, subtract(time(),@time))
    assign(@days,floor(divide(@diff,86400000)))
    assign(@hours,floor(divide(mod(@diff,86400000),3600000)))
    assign(@minutes,floor(divide(mod(@diff,3600000),60000)))
    if(is_null(@jailreason),
        msg(color(Green),'No record of ',@player,' being jailed.')
        ,#else
        msg(concat(color(Green),'Player ',@player,' jailed for ',@jailreason,' for ',@jaillength,' by ',@jailmod,', ',@days,' days, ',@hours,' hours and ',@minutes,' mins ago. Player has been jailed ',@jailcount,'times'))
        )

)

proc(_ban, @cmnd, @player, @datediff, @reason,
    assign(@banmod,player())
    if(equals(length(@reason),0),
        msg('Ban a user.')
        if(equals(@cmnd,'/tempban'),
            msg(@cmnd,' <playername> <datediff> <reason>')
            ,#else
            msg(@cmnd,' <playername> <reason>')
        )
    ,#else
        try(
            assign(@player,player(@player)),
            @var,
            assign(@player,@player)
            msg(color(red),'User offline. I hope you got their name right.')
        )
        if(equals(@cmnd,'/tempban'),
            run(@cmnd @player @datediff @reason)
            ,#else
            run(@cmnd @player @reason)
        )
        assign(@lcpl,to_lower(@player))

        #check the record count
        assign(@rcount, get_value(concat('bandb.',@lcpl,'.ban.rcount')))
        if(is_null(@rcount),assign(@rcount,1),assign(@rcount,inc(@rcount)))
        store_value(concat('bandb.',@lcpl,'.ban.rcount'),@rcount)
        store_value(concat('bandb.',@lcpl,'.ban.',@rcount,'.reason'), @reason)
        store_value(concat('bandb.',@lcpl,'.ban.',@rcount,'.length'), @datediff)
        store_value(concat('bandb.',@lcpl,'.ban.',@rcount,'.mod'), @banmod)
        store_value(concat('bandb.',@lcpl,'.ban.',@rcount,'.time'), time())

        #the ban count is not the same as the record count as some old records are not saved in bandb
        assign(@bancount, get_value(concat('bandb.',@lcpl,'.ban.count')))
        if(is_null(@bancount),assign(@bancount,0))
        store_value(concat('bandb.',@lcpl,'.ban.count'),inc(@bancount))
    )
)

proc(_banq,@player,
    assign(@lcplayer,to_lower(@player))
    assign(@rcount, get_value(concat('bandb.',@lcplayer,'.ban.rcount')))
    if(is_null(@rcount),assign(@rcount,0))
    assign(@banreason,get_value(concat('bandb.',@lcplayer,'.ban.',@rcount,'.reason')))
    assign(@banlength,get_value(concat('bandb.',@lcplayer,'.ban.',@rcount,'.length')))
    assign(@bancount,get_value(concat('bandb.',@lcplayer,'.ban.count')))
    assign(@banmod,get_value(concat('bandb.',@lcplayer,'.ban.',@rcount,'.mod')))
    assign(@time,get_value(concat('bandb.',@lcplayer,'.ban.',@rcount,'.time')))
    if(is_null(@time),assign(@time,0))
    assign(@diff, subtract(time(),@time))
    assign(@days,floor(divide(@diff,86400000)))
    assign(@hours,floor(divide(mod(@diff,86400000),3600000)))
    assign(@minutes,floor(divide(mod(@diff,3600000),60000)))
    if(is_null(@jailreason),
        msg(color(Green),'No record of ',@player,' being banned.')
        ,#else
        msg(color(Green),'Player ',@player,' banned for ',@banreason,' for ',@banlength,' by ',@banmod,', ',
            @days,' days, ',@hours,' hours and ',@minutes,' mins ago. Player has been banned ',@bancount,' times')
        )

)


proc(_modlist,
assign(@operatorlist,range(0))
assign(@adminlist,range(0))
assign(@modslist,range(0))
assign(@players,all_players())

msg(color(AQUA)'Staff members currently online:')
foreach(@players,@pl,
  if(array_contains(pinfo(@pl,9),Operator),
        array_push(@adminlist,concat(color(YELLOW),'  ',color(RED),pinfo(@pl,4),color(WHITE)))
    )
    if(array_contains(pinfo(@pl,9),Admin),
        array_push(@adminlist,concat(color(YELLOW),'  ',color(RED),pinfo(@pl,4),color(WHITE)))
    )
    if(array_contains(pinfo(@pl,9),Mod),
        array_push(@modslist,concat(color(YELLOW),'  ',color(BLUE),pinfo(@pl,4),color(WHITE)))
    )
)

msg(concat(color(AQUA),'###################',color(red),' Administrators ',color(AQUA),'###################'))
msg(array_implode(@adminlist),'  ')
msg(concat(color(AQUA),'###################',color(blue),' Moderators ',color(AQUA),'###################'))
msg(array_implode(@modslist),'  ')

)

