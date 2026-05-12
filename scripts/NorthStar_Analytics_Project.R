# =============================================================
# NorthStar Urban Mobility - SQL in R
# Complete Working Script
# =============================================================

# ── STEP 1: Set Working Directory ────────────────────────────
setwd("C:/Users/chamo/Desktop/NorthStar_Analytics_Project")

# ── STEP 2: Install & Load Packages ──────────────────────────
if(!require(sqldf)) install.packages("sqldf")
if(!require(readr)) install.packages("readr")  
if(!require(dplyr)) install.packages("dplyr")

library(sqldf)
library(readr)
library(dplyr)

# ── STEP 3: Create Sample Data (if CSV files don't exist) ────
cat("📁 Checking for CSV files...\n")

if(!file.exists("data/deliveries.csv")) {
  cat("Creating sample data...\n")
  
  set.seed(123)
  
  # Hubs
  hubs <- data.frame(
    hub_id = paste0("HUB", 1:5),
    hub_name = c("Central Hub", "North Hub", "South Hub", "East Hub", "West Hub"),
    zone = c("Downtown", "Uptown", "Suburb", "Industrial", "Airport"),
    hub_type = c("Main", "Satellite", "Satellite", "Satellite", "Main")
  )
  
  # Customers
  customers <- data.frame(
    customer_id = paste0("CUST", 1:50),
    customer_name = paste("Customer", 1:50),
    customer_zone = sample(c("Downtown", "Uptown", "Suburb", "Airport"), 50, replace = TRUE),
    loyalty_tier = sample(c("Gold", "Silver", "Bronze"), 50, replace = TRUE)
  )
  
  # Drivers
  drivers <- data.frame(
    driver_id = paste0("DRV", 1:20),
    base_zone = sample(c("Downtown", "Uptown", "Suburb", "Airport"), 20, replace = TRUE),
    employment_type = sample(c("FullTime", "PartTime", "Contract"), 20, replace = TRUE),
    years_experience = round(runif(20, 0.5, 10), 1),
    training_score = round(runif(20, 60, 100), 1),
    driver_rating = round(runif(20, 3, 5), 1)
  )
  
  # Vehicles
  vehicles <- data.frame(
    vehicle_id = paste0("VEH", 1:25),
    hub_id = sample(hubs$hub_id, 25, replace = TRUE),
    vehicle_type = sample(c("Car", "Van", "Scooter", "Bike"), 25, replace = TRUE),
    fuel_efficiency = round(runif(25, 15, 35), 1)
  )
  
  # Orders
  orders <- data.frame(
    order_id = paste0("ORD", 1:200),
    customer_id = sample(customers$customer_id, 200, replace = TRUE),
    service_type = sample(c("Passenger", "Parcel", "Business", "Food"), 200, replace = TRUE),
    order_value = round(runif(200, 20, 300), 2),
    pickup_zone = sample(c("Downtown", "Uptown", "Suburb", "Airport", "Industrial"), 200, replace = TRUE),
    dropoff_zone = sample(c("Downtown", "Uptown", "Suburb", "Airport", "Industrial"), 200, replace = TRUE),
    priority_level = sample(c("Low", "Medium", "High", "Urgent"), 200, replace = TRUE),
    booking_channel = sample(c("App", "Web", "Call", "API"), 200, replace = TRUE),
    promised_window_hours = round(runif(200, 0.5, 4), 1)
  )
  
  # Deliveries
  deliveries <- data.frame(
    delivery_id = paste0("DEL", 1:200),
    order_id = orders$order_id,
    driver_id = sample(drivers$driver_id, 200, replace = TRUE),
    hub_id = sample(hubs$hub_id, 200, replace = TRUE),
    delivery_status = sample(c("OnTime", "Delayed", "Failed"), 200, replace = TRUE, prob = c(0.7, 0.2, 0.1)),
    route_distance_km = round(runif(200, 2, 50), 1),
    manual_route_override_count = sample(0:5, 200, replace = TRUE, prob = c(0.8, 0.1, 0.05, 0.03, 0.01, 0.01)),
    proof_of_completion_missing = sample(c(TRUE, FALSE), 200, replace = TRUE, prob = c(0.05, 0.95)),
    customer_rating_post_delivery = round(runif(200, 1, 5), 1),
    fuel_or_charge_cost = round(runif(200, 5, 30), 2)
  )
  
  # Complaints
  complaints <- data.frame(
    complaint_id = paste0("COMP", 1:40),
    customer_id = sample(customers$customer_id, 40, replace = TRUE),
    order_id = sample(orders$order_id, 40, replace = TRUE),
    complaint_type = sample(c("Late", "Damaged", "Wrong Item", "Driver Behaviour", "Billing"), 40, replace = TRUE),
    severity = sample(c("Low", "Medium", "High", "Critical"), 40, replace = TRUE),
    status = sample(c("Open", "Resolved", "Escalated"), 40, replace = TRUE),
    resolution_days = sample(0:10, 40, replace = TRUE),
    compensation_amount = round(runif(40, 0, 50), 2)
  )
  
  # Incidents
  incidents <- data.frame(
    incident_id = paste0("INC", 1:30),
    driver_id = sample(drivers$driver_id, 30, replace = TRUE),
    incident_type = sample(c("Traffic", "Accident", "Vehicle Issue", "Customer", "Weather"), 30, replace = TRUE),
    severity = sample(c("Low", "Medium", "High"), 30, replace = TRUE),
    reported_date = paste0("2024-", sample(1:12, 30), "-", sample(1:28, 30))
  )
  
  # Save all CSV files
  write.csv(hubs, "data/hubs.csv", row.names = FALSE)
  write.csv(customers, "data/customers.csv", row.names = FALSE)
  write.csv(drivers, "data/drivers.csv", row.names = FALSE)
  write.csv(vehicles, "data/vehicles.csv", row.names = FALSE)
  write.csv(orders, "data/orders.csv", row.names = FALSE)
  write.csv(deliveries, "data/deliveries.csv", row.names = FALSE)
  write.csv(complaints, "data/complaints.csv", row.names = FALSE)
  write.csv(incidents, "data/incidents.csv", row.names = FALSE)
  
  cat("✅ 8 CSV files created in 'data' folder\n\n")
} else {
  cat("✅ CSV files already exist, loading them...\n")
  
  # Load existing CSV files
  hubs <- read_csv("data/hubs.csv")
  customers <- read_csv("data/customers.csv")
  drivers <- read_csv("data/drivers.csv")
  vehicles <- read_csv("data/vehicles.csv")
  orders <- read_csv("data/orders.csv")
  deliveries <- read_csv("data/deliveries.csv")
  complaints <- read_csv("data/complaints.csv")
  incidents <- read_csv("data/incidents.csv")
}

# Quick check
cat("\n📊 Data loaded successfully!\n")
cat("Deliveries:", nrow(deliveries), "rows\n")
cat("Orders:", nrow(orders), "rows\n")
cat("Drivers:", nrow(drivers), "rows\n\n")

# =============================================================
# QUERY 1: Deliveries + Orders JOIN
# =============================================================
query1 <- sqldf("
  SELECT
    d.delivery_id,
    d.order_id,
    d.driver_id,
    d.hub_id,
    d.delivery_status,
    d.route_distance_km,
    d.manual_route_override_count,
    d.customer_rating_post_delivery,
    d.fuel_or_charge_cost,
    o.service_type,
    o.order_value,
    o.pickup_zone,
    o.dropoff_zone,
    o.priority_level,
    o.booking_channel,
    o.promised_window_hours
  FROM deliveries d
  JOIN orders o ON d.order_id = o.order_id
")

cat("\n=== QUERY 1: Deliveries + Orders JOIN ===\n")
print(head(query1, 10))
cat("Total joined records:", nrow(query1), "\n")

# =============================================================
# QUERY 2: Zone-by-Zone Delivery Failure Rates
# =============================================================
query2 <- sqldf("
  SELECT
    UPPER(o.pickup_zone) AS zone,
    COUNT(*) AS total_deliveries,
    SUM(CASE WHEN d.delivery_status = 'Failed' THEN 1 ELSE 0 END) AS failed_count,
    SUM(CASE WHEN d.delivery_status = 'Delayed' THEN 1 ELSE 0 END) AS delayed_count,
    SUM(CASE WHEN d.delivery_status = 'OnTime' THEN 1 ELSE 0 END) AS ontime_count,
    ROUND(100.0 * SUM(CASE WHEN d.delivery_status = 'Failed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS failure_rate_pct,
    ROUND(100.0 * SUM(CASE WHEN d.delivery_status = 'Delayed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS delay_rate_pct
  FROM deliveries d
  JOIN orders o ON d.order_id = o.order_id
  GROUP BY UPPER(o.pickup_zone)
  ORDER BY failure_rate_pct DESC
")

cat("\n=== QUERY 2: Zone-by-Zone Delivery Failure & Delay Rates ===\n")
print(query2)

# =============================================================
# QUERY 3: Driver Performance Analysis
# =============================================================
query3 <- sqldf("
  SELECT
    dr.driver_id,
    dr.base_zone,
    dr.employment_type,
    dr.years_experience,
    dr.training_score,
    dr.driver_rating,
    COUNT(d.delivery_id) AS total_deliveries,
    SUM(CASE WHEN d.delivery_status = 'OnTime' THEN 1 ELSE 0 END) AS ontime_count,
    SUM(CASE WHEN d.delivery_status = 'Failed' THEN 1 ELSE 0 END) AS failed_count,
    SUM(CASE WHEN d.delivery_status = 'Delayed' THEN 1 ELSE 0 END) AS delayed_count,
    ROUND(100.0 * SUM(CASE WHEN d.delivery_status = 'OnTime' THEN 1 ELSE 0 END) / COUNT(*), 2) AS ontime_rate_pct,
    ROUND(AVG(d.customer_rating_post_delivery), 2) AS avg_customer_rating,
    ROUND(AVG(d.fuel_or_charge_cost), 2) AS avg_fuel_cost,
    SUM(d.manual_route_override_count) AS total_manual_overrides
  FROM drivers dr
  JOIN deliveries d ON dr.driver_id = d.driver_id
  GROUP BY dr.driver_id
  HAVING total_deliveries >= 3
  ORDER BY ontime_rate_pct DESC
")

cat("\n=== QUERY 3: Driver Performance Ranked by On-Time Rate ===\n")
print(head(query3, 15))

cat("\n--- Top 5 Best Performing Drivers ---\n")
print(head(query3, 5))

cat("\n--- Bottom 5 Underperforming Drivers ---\n")
print(tail(query3, 5))

# =============================================================
# QUERY 4: Late Deliveries Filter
# =============================================================
query4 <- sqldf("
  SELECT
    d.delivery_id,
    d.driver_id,
    d.hub_id,
    d.delivery_status,
    d.route_distance_km,
    d.manual_route_override_count,
    d.proof_of_completion_missing,
    d.customer_rating_post_delivery,
    o.pickup_zone,
    o.dropoff_zone,
    o.service_type,
    o.priority_level,
    o.promised_window_hours,
    o.order_value
  FROM deliveries d
  JOIN orders o ON d.order_id = o.order_id
  WHERE d.delivery_status IN ('Failed', 'Delayed')
  ORDER BY o.order_value DESC
")

cat("\n=== QUERY 4: All Late Deliveries (Failed + Delayed) ===\n")
cat("Total late deliveries:", nrow(query4), "\n")
print(head(query4, 10))

# =============================================================
# QUERY 5: High-Value Orders That Failed
# =============================================================
query5 <- sqldf("
  SELECT
    d.delivery_id,
    o.order_id,
    o.customer_id,
    o.service_type,
    UPPER(o.pickup_zone) AS pickup_zone,
    o.order_value,
    d.delivery_status,
    d.driver_id,
    d.customer_rating_post_delivery
  FROM deliveries d
  JOIN orders o ON d.order_id = o.order_id
  WHERE d.delivery_status = 'Failed'
    AND o.order_value > 100
  ORDER BY o.order_value DESC
")

cat("\n=== QUERY 5: High-Value Orders That Failed (>£100) ===\n")
print(head(query5, 10))
cat("Count of high-value failures:", nrow(query5), "\n")

# =============================================================
# QUERY 6: Hub Performance Summary
# =============================================================
query6 <- sqldf("
  SELECT
    d.hub_id,
    h.hub_name,
    h.zone,
    h.hub_type,
    COUNT(d.delivery_id) AS total_deliveries,
    SUM(CASE WHEN d.delivery_status = 'OnTime' THEN 1 ELSE 0 END) AS ontime,
    SUM(CASE WHEN d.delivery_status = 'Failed' THEN 1 ELSE 0 END) AS failed,
    SUM(CASE WHEN d.delivery_status = 'Delayed' THEN 1 ELSE 0 END) AS delayed,
    ROUND(100.0 * SUM(CASE WHEN d.delivery_status = 'Failed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS failure_rate_pct,
    ROUND(AVG(d.customer_rating_post_delivery), 2) AS avg_rating
  FROM deliveries d
  JOIN hubs h ON d.hub_id = h.hub_id
  GROUP BY d.hub_id
  ORDER BY failure_rate_pct DESC
")

cat("\n=== QUERY 6: Hub Performance Summary ===\n")
print(query6)

# =============================================================
# QUERY 7: Manual Route Overrides by Zone
# =============================================================
query7 <- sqldf("
  SELECT
    UPPER(o.pickup_zone) AS zone,
    COUNT(*) AS total_deliveries,
    SUM(d.manual_route_override_count) AS total_overrides,
    ROUND(AVG(d.manual_route_override_count), 2) AS avg_overrides_per_trip,
    SUM(CASE WHEN d.manual_route_override_count > 0 THEN 1 ELSE 0 END) AS trips_with_override
  FROM deliveries d
  JOIN orders o ON d.order_id = o.order_id
  GROUP BY UPPER(o.pickup_zone)
  ORDER BY avg_overrides_per_trip DESC
")

cat("\n=== QUERY 7: Manual Route Overrides by Zone ===\n")
print(query7)

# =============================================================
# QUERY 8: Service Type Performance Comparison
# =============================================================
query8 <- sqldf("
  SELECT
    o.service_type,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN d.delivery_status = 'OnTime' THEN 1 ELSE 0 END) AS ontime,
    SUM(CASE WHEN d.delivery_status = 'Failed' THEN 1 ELSE 0 END) AS failed,
    SUM(CASE WHEN d.delivery_status = 'Delayed' THEN 1 ELSE 0 END) AS delayed,
    ROUND(100.0 * SUM(CASE WHEN d.delivery_status = 'Failed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS failure_rate_pct,
    ROUND(AVG(o.order_value), 2) AS avg_order_value,
    ROUND(AVG(d.customer_rating_post_delivery), 2) AS avg_rating
  FROM deliveries d
  JOIN orders o ON d.order_id = o.order_id
  GROUP BY o.service_type
  ORDER BY failure_rate_pct DESC
")

cat("\n=== QUERY 8: Performance by Service Type ===\n")
print(query8)

# =============================================================
# QUERY 9: Drivers with High Failure + Low Rating
# =============================================================
query9 <- sqldf("
  SELECT
    dr.driver_id,
    dr.base_zone,
    dr.employment_type,
    dr.training_score,
    dr.driver_rating AS profile_rating,
    COUNT(d.delivery_id) AS total_deliveries,
    SUM(CASE WHEN d.delivery_status = 'Failed' THEN 1 ELSE 0 END) AS failed_count,
    ROUND(100.0 * SUM(CASE WHEN d.delivery_status = 'Failed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS failure_rate_pct,
    ROUND(AVG(d.customer_rating_post_delivery), 2) AS avg_post_delivery_rating
  FROM drivers dr
  JOIN deliveries d ON dr.driver_id = d.driver_id
  GROUP BY dr.driver_id
  HAVING failure_rate_pct > 15
     AND avg_post_delivery_rating < 3.5
  ORDER BY failure_rate_pct DESC
")

cat("\n=== QUERY 9: High-Risk Drivers (Failure > 15% AND Rating < 3.5) ===\n")
print(query9)

# =============================================================
# QUERY 10: Complaint + Delivery JOIN
# =============================================================
query10 <- sqldf("
  SELECT
    c.complaint_id,
    c.customer_id,
    c.complaint_type,
    c.severity,
    c.status AS complaint_status,
    c.resolution_days,
    c.compensation_amount,
    d.delivery_status,
    d.driver_id,
    o.pickup_zone,
    o.service_type
  FROM complaints c
  JOIN orders o ON c.order_id = o.order_id
  JOIN deliveries d ON o.order_id = d.order_id
  ORDER BY c.compensation_amount DESC
")

cat("\n=== QUERY 10: Complaints Linked to Delivery Data ===\n")
print(head(query10, 10))
cat("Total complaint-delivery records:", nrow(query10), "\n")

# =============================================================
# SUMMARY OUTPUT
# =============================================================
cat("\n========================================\n")
cat("       NorthStar SQL in R - Summary\n")
cat("========================================\n")
cat("Total deliveries analysed   :", nrow(deliveries), "\n")
cat("Total orders in dataset     :", nrow(orders), "\n")
cat("Joined records (Q1)         :", nrow(query1), "\n")
cat("Late deliveries (Q4)        :", nrow(query4), "\n")
cat("High-value failures (Q5)    :", nrow(query5), "\n")
cat("High-risk drivers (Q9)      :", nrow(query9), "\n")
cat("========================================\n")

cat("\n✅ Analysis complete!\n")