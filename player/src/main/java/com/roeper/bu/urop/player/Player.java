package com.roeper.bu.urop.player;

import java.io.FileNotFoundException;
import java.util.Date;

import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.inject.Guice;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.name.Named;
import com.roeper.bu.urop.lib.ConfigReader;
import com.roeper.bu.urop.lib.SensorReading;
import com.roeper.bu.urop.lib.SensorReadingReader;

public class Player
{
	public static void main(String args[]) throws Exception
	{
		String configFile = "config.yml";
		if (args.length == 1)
		{
			configFile = args[0];
		}

		// get the config
		PlayerModuleConfig config = null;
		ConfigReader<PlayerModuleConfig> reader = new ConfigReader<PlayerModuleConfig>(PlayerModuleConfig.class);
		try
		{
			config = reader.read(configFile);
		}
		catch (Exception e)
		{
			e.printStackTrace();
			throw new RuntimeException("Error getting config");
		}

		Injector injector = Guice.createInjector(new PlayerModule(config));

		// create recorder
		final Player recorder = injector.getInstance(Player.class);

		// add shutdown hook
		Runtime.getRuntime().addShutdownHook(new Thread()
		{
			@Override
			public void run()
			{
				recorder.stop();
			}
		});

		// start recorder
		recorder.play();
	}

	final Logger logger = LoggerFactory.getLogger(Player.class);
	private SensorReadingReader reader;
	private MqttClient client;
	private String topicPrefix;

	@Inject
	protected Player(	SensorReadingReader aReader, MqttClient aClient,
						@Named("topicPrefix") String aTopicPrefix)
	{
		this.reader = aReader;
		this.client = aClient;
		this.topicPrefix = aTopicPrefix;
	}

	public void play()
	{
		try
		{
			this.reader.open();

			MqttConnectOptions connOpts = new MqttConnectOptions();
			connOpts.setCleanSession(true);
			client.connect(connOpts);
			logger.info("Successfully connected to broker.");

			logger.info("Playing...");
			if (this.reader.hasNext())
			{
				// publish first one
				SensorReading first = this.reader.next();
				publishReading(first);
				Date lastTime = first.getReceived();

				while (this.reader.hasNext())
				{
					SensorReading next = this.reader.next();

					// wait for time in between readings
					long millisecondsBetween = next.getReceived().getTime() - lastTime.getTime();
					lastTime = next.getReceived();
					Thread.sleep(millisecondsBetween);

					// publish the reading
					publishReading(next);
				}
			}

			logger.info("Done");
		}
		catch (InterruptedException e)
		{
			e.printStackTrace();
		}
		catch (MqttException me)
		{
			logger.error("An error occured connecting to the broker");
			me.printStackTrace();
		}
		catch (FileNotFoundException ea)
		{
			logger.error("The input file was not found");
			ea.printStackTrace();
		}
		finally
		{
			this.stop();
		}
	}

	private void publishReading(SensorReading aReading) throws MqttException
	{
		String topic = this.topicPrefix + "/group/" + aReading.getGroupId() + "/sensor/" + aReading.getSensorId();
		String payload = aReading.getPayload();
		MqttMessage message = new MqttMessage(payload.getBytes());
		message.setQos(2);
		client.publish(topic, message);
	}

	public void stop()
	{
		this.reader.close();

		try
		{
			if (this.client.isConnected())
			{
				this.client.disconnect();
			}
		}
		catch (MqttException e)
		{
			e.printStackTrace();
		}
	}
}