extends Effect
class_name Sleep

var wake_up_damage : float


func apply():
	p.moveable -=1
	p.able_to_basic -= 1
	p.castable -= 1
	p.connect("taken_damage",self,"wake_up")

func wake_up(total_damage,source):
	if expired: return
	expire()
	var damage = Damage.new()
	damage.true_damage = wake_up_damage
	p.take_damage(Dicts.damage_to_dict(damage),p.get_path_to(source))
	
	
func expire():
	if expired: return
	.expire()
	p.moveable +=1
	p.able_to_basic += 1
	p.castable += 1
