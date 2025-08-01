require './db/mysql_connector.rb'

class Item
    attr_accessor :id, :name, :price, :category

    def initialize(params)
        @id = params[:id]
        @name = params[:name]
        @price = params[:price]
        @category = params[:category] ? params[:category] : nil
    end

    def save
        client = create_db_client
        # statement = client.prepare("INSERT INTO items (name, price) VALUES (?, ?)")
        # result = statement.execute(@name, @price)
        client.query("INSERT INTO items (name, price) VALUES (#{@name}, #{@price})")
    end

    def generate_id
        client = create_db_client
        statement = client.prepare("SELECT id from items")
        result = statement.execute()
        return result.count
    end

    def self.get_all
        @client = create_db_client
        rawData = @client.query(
            "SELECT items.id as id, items.name as name, items.price as price, categories.name as category_name, categories.id as category_id FROM items JOIN item_categories JOIN categories WHERE items.id = item_categories.item_id and categories.id = item_categories.category_id"
        )
        items = []
        rawData.each do |data|
            category = Category.new({"id": data["category_id"], "name": data["category_name"]})
            item = Item.new({"id": data["id"], "name": data["name"], "price": data["price"], "category": category})
            items.push(item)
        end
        items
    end

    def self.find_by_id(id)
        client = create_db_client
        # statement = client.prepare("select * from (select * from items where id = ?) item inner join item_categories on item_id = item.id")
        # result = statement.execute(id)
        result = client.query("select * from (select * from items where id = #{id}) item inner join item_categories on item_id = item.id")
        return nil unless result.count > 0
        data = result.first
        Item.new({"id": data['id'], "name": data['name'], "price": data['price'], "category": data['category_id']})
    end

    def self.find_by_category(id)
        client = create_db_client
        # statement = client.prepare("select * from items inner join item_categories on items.id = item_categories.item_id where item_categories.category_id = ?")
        # result = statement.execute(id)
        result = client.query("select * from items inner join item_categories on items.id = item_categories.item_id where item_categories.category_id = #{id}")
        return nil unless result.count > 0
        items = Array.new
        result.each do |data|
            item = Item.new({"id": data['id'], "name": data['name'], "price": data['price'], "category": id})
            items.push(item)
        end
        items
    end

    def update
        client = create_db_client
        # statement = client.prepare("UPDATE item_categories SET category_id=? WHERE item_id = ?")
        # result = statement.execute(@category, @id)
        client.query("UPDATE item_categories SET category_id=#{@category} WHERE item_id = #{@id}")
        # statement = client.prepare("UPDATE items SET name=?, price=? WHERE id = ?")
        # result = statement.execute(@name, @price, @id)
        client.query("UPDATE items SET name=#{@name}, price=#{@price} WHERE id = #{@id}")
    end

    def delete
        client = create_db_client
        # statement = client.prepare("DELETE FROM order_items WHERE item_id = ?")
        # result = statement.execute(@id)
        client.query("DELETE FROM order_items WHERE item_id = #{@id}")
        # statement = client.prepare("DELETE FROM item_categories WHERE item_id = ?")
        # result = statement.execute(@id)
        client.query("DELETE FROM item_categories WHERE item_id = #{@id}")
        # statement = client.prepare("DELETE FROM items WHERE id = ?")
        # result = statement.execute(@id)
        client.query("DELETE FROM items WHERE id = #{@id}")
    end

    def valid?
        return false if name.nil? || price.nil?

        true
    end
end