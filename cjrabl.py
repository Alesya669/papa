class FlyingShip:
    def __init__(self, speed, height, passengers):
        self.speed = speed
        self.height = height
        self.passengers = passengers

    def change_speed(self, value):
        self.speed += value
        if self.speed < 0:
            self.speed = 0

    def change_height(self, value):
        self.height += value
        if self.height < 0:
            self.height = 0

    def add_passengers(self, value):
        self.passengers += value

    def remove_passengers(self, value):
        self.passengers -= value
        if self.passengers < 0:
            self.passengers = 0

    def get_capacity(self):
        return [self.speed, self.height, self.passengers]

    def __str__(self):
        return (f"Летающий корабль. скорость: {self.speed} км/ч , высота: "
                f"{self.height} метров, на борту: {self.passengers} пассажиров")

    # Сравнение: сначала по пассажирам, затем по скорости, затем по высоте
    def __eq__(self, other):
        if not isinstance(other, FlyingShip):
            return NotImplemented
        return (self.passengers, self.speed, self.height) == \
               (other.passengers, other.speed, other.height)

    def __lt__(self, other):
        if not isinstance(other, FlyingShip):
            return NotImplemented
        return (self.passengers, self.speed, self.height) < \
               (other.passengers, other.speed, other.height)

    def __le__(self, other):
        if not isinstance(other, FlyingShip):
            return NotImplemented
        return (self.passengers, self.speed, self.height) <= \
               (other.passengers, other.speed, other.height)

    def __gt__(self, other):
        if not isinstance(other, FlyingShip):
            return NotImplemented
        return (self.passengers, self.speed, self.height) > \
               (other.passengers, other.speed, other.height)

    def __ge__(self, other):
        if not isinstance(other, FlyingShip):
            return NotImplemented
        return (self.passengers, self.speed, self.height) >= \
               (other.passengers, other.speed, other.height)


class Fighter(FlyingShip):
    def __init__(self, speed, height, passengers, weapons_count):
        super().__init__(speed, height, passengers)
        self.weapons_count = weapons_count

    def __str__(self):
        base = super().__str__()
        return f"Истребитель ({base}, вооружение: {self.weapons_count})"


# Пример использования
if __name__ == "__main__":
    ship1 = FlyingShip(100, 500, 20)
    ship2 = FlyingShip(150, 800, 20)

    print(ship1)
    ship1.change_speed(50)
    ship1.change_height(-600)  # не станет ниже 0
    ship1.add_passengers(5)
    ship1.remove_passengers(30)  # не станет ниже 0
    print(ship1.get_capacity())
    print(ship1)

    print("ship1 > ship2:", ship1 > ship2)  # по пассажирам, скорости, высоте

    f = Fighter(300, 1000, 2, 4)
    print(f)
    print(f.get_capacity())
